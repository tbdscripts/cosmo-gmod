function Cosmo:checkForPendingTransactions()
  self:logDebug("Checking for pending transactions...")

  self.DB:getPendingTransactions()
    :resolved(function(data)
      if self.Config.Debug then
        self:logDebug("Attemping to handle " .. table.Count(data) .. " pending transactions.")
      end

      for _, transaction in pairs(data) do
        self:handlePendingTransaction(transaction)
      end
    end)
    :rejected(function(err)
      self:log("(ERROR) Checking for pending transactions failed.")
    end)
end

function Cosmo:handlePendingTransaction(transaction)
  local ply = player.GetBySteamID64(transaction.receiver)
  if not IsValid(ply) then return end

  self.DB:getPendingTransactionActions(transaction.id)
    :resolved(function(data)
      local hasFailed = false

      for _, action in pairs(data) do
        local success = self:handlePendingAction(ply, transaction, action)
        if not success then
          hasFailed = true
        end
      end

      if not hasFailed then
        self.DB:deliverTransaction(transaction.id)
      end

      self.Network:sendPurchaseNotification(ply, transaction.package_name)
    end)
    :rejected(function(err)
      self:log("(ERROR) Pulling pending actions for transaction (" .. transaction.id .. ") failed.")
      self:logDebug(err)
    end)
end

function Cosmo:handlePendingAction(ply, transaction, action)
  if transaction.receiver ~= action.receiver or transaction.receiver ~= ply:SteamID64() then return end

  local actionType = Cosmo.ActionType.get(action.name)
  if not actionType then
    self:logDebug(string.format("Invalid action type '%s' on action: %s", action.name, action.id))
    return
  end

  self:logDebug("Handling action: " .. action.id)

  local data = util.JSONToTable(action.data) or {}
  local result = actionType:handle(ply, data)
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

  self:logDebug("Handling expired action: " .. action.id)

  local data = util.JSONToTable(action.data) or {}
  local result = actionType:onExpired(ply, data)
  if not result then return end

  self.DB:expireAction(action.id)
  self:logDebug("Finished handling expired action: " .. action.id)
end

local CurTime = CurTime
local nextCheck = CurTime()

-- Using a Think hook because timer.Create tends to desync if the server has been up for long
hook.Add("Think", "Cosmo.CheckForPendingTransactions", function()
  local curTime = CurTime()
  if nextCheck > curTime then return end
  
  Cosmo:checkForPendingTransactions()
  Cosmo:checkForExpiredActions()

  nextCheck = curTime + Cosmo.Config.CheckTime
end)