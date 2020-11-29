function Cosmo:HandlePendingActions()
  self.DB:getPendingActions()
    :resolved(function(data)
      self:logDebug("Handling", #data, "pending actions.")

      for _, action in ipairs(data) do
        self:HandleAction(action)
      end
    end)
end

function Cosmo:HandleAction(action)
  local sid64 = action.receiver
  local ply = player.GetBySteamID64(sid64)
  if not IsValid(ply) then return end -- Player has to be online

  local actionType = self.ActionType.get(action.name)
  if not actionType then return end

  local data = util.JSONToTable(action.data) or {}

  local success = actionType:handle(ply, data)
  if not success then return end

  self.DB:completeAction(action.id)
end

timer.Create("Cosmo.CheckForNewActions", Cosmo.Config.CheckTime, 0, function()
  Cosmo:HandlePendingActions()
end)