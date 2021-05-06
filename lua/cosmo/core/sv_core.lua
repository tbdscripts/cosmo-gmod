function Cosmo:checkForPendingOrders()
  self:logDebug("Checking for pending orders...")

  self.DB:getPendingOrders()
    :resolved(function(data)
      if self.Config.Debug then
        self:logDebug("Attemping to handle " .. table.Count(data) .. " pending orders.")
      end

      for _, order in pairs(data) do
        self:handlePendingOrder(order)
      end
    end)
    :rejected(function(err)
      self:log("(ERROR) Checking for pending orders failed.")
    end)
end

function Cosmo:handlePendingOrder(order)
  local ply = player.GetBySteamID64(order.receiver)
  if not IsValid(ply) then return end

  self.DB:getPendingOrderActions(order.id)
    :resolved(function(data)
      local hasFailed = false

      for _, action in pairs(data) do
        local success = self:handlePendingAction(ply, order, action)
        if not success then
          hasFailed = true
        end
      end

      if not hasFailed then
        self.DB:deliverOrder(order.id)
        self.Network:sendPurchaseNotification(ply, order.package_name)
      end
    end)
    :rejected(function(err)
      self:log("(ERROR) Pulling pending actions for order (" .. order.id .. ") failed.")
      self:logDebug(err)
    end)
end

function Cosmo:handlePendingAction(ply, order, action)
  if order.receiver ~= action.receiver or order.receiver ~= ply:SteamID64() then return end

  local actionType = Cosmo.ActionType.get(action.name)
  if not actionType then
    self:logDebug(string.format("Invalid action type '%s' on action: %s", action.name, action.id))
    return
  end

  if not isfunction(actionType.onBought) then return end

  self:logDebug("Handling action: " .. action.id)

  local data = util.JSONToTable(action.data) or {}
  local result = actionType:onBought(ply, data)
  if not result then return end

  self.DB:completeAction(action.id)
  self:logDebug("Finished handling action: " .. action.id)

  return true
end

function Cosmo:checkForExpiredActions()
  self:logDebug("Checking for expired actions...")

  self.DB:getExpiredActions()
    :resolved(function(data)
      if self.Config.Debug then
        self:logDebug("Attemping to handle " .. table.Count(data) .. " expired actions.")
      end

      for _, action in pairs(data) do
        self:handleExpiredAction(action)
      end
    end)
    :rejected(function(err)
      self:log("(ERROR) Checking for expired actions failed.")
    end)
end

function Cosmo:handleExpiredAction(action)
  local ply = player.GetBySteamID64(action.receiver)
  if not IsValid(ply) then return end

  local actionType = self.ActionType.get(action.name)
  if not actionType then
    self:logDebug("Expired action (" .. action.id .. ") has an invalid action type: " .. action.name)
    return
  end

  if not isfunction(actionType.onExpired) then return end

  self:logDebug("Handling expired action: " .. action.id)

  local data = util.JSONToTable(action.data) or {}
  local result = actionType:onExpired(ply, data, action)
  if not result then return end

  self.DB:expireAction(action.id)
  self:logDebug("Finished handling expired action: " .. action.id)
end

local CurTime = CurTime
local nextCheck = CurTime()

-- Using a Think hook because timer.Create tends to desync if the server has been up for long
hook.Add("Think", "Cosmo.CheckForPendingOrders", function()
  local curTime = CurTime()
  if nextCheck > curTime then return end
  
  Cosmo:checkForPendingOrders()
  Cosmo:checkForExpiredActions()

  nextCheck = curTime + Cosmo.Config.CheckTime
end)

hook.Add("PlayerSay", "Cosmo.DonateCommand", function(ply, text)
  if not IsValid(ply) or text ~= Cosmo.Config.ChatCommand then return end

  Cosmo.Network:openDonateCommand(ply)
end)