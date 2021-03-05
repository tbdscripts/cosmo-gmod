local WEAPONS = Cosmo.ActionType.new("weapons")

local function giveWeapons(ply, classes)
  if not istable(classes) then return end

  for _, class in ipairs(classes) do
    ply:Give(class)
  end
end

function WEAPONS:onBought(ply, data)
  local classes = data.classes or {}
  giveWeapons(ply, classes)

  return true
end

function WEAPONS:onExpire(ply, _, action)
  local actionId = action.id
  if not actionId then return end

  for i, wAction in pairs(ply.__cosmoWeapons) do
    if action.id == wAction.id then
      ply.__cosmoWeapons[i] = nil
      break
    end
  end
end

WEAPONS:addHook("PlayerLoadout", function(ply)
  if not ply.__cosmoWeapons then return end

  for _, action in pairs(ply.__cosmoWeapons) do
    giveWeapons(ply, action.data.classes)
  end
end)

WEAPONS:addHook("PlayerInitialSpawn", function(ply)
  local sid64 = ply:SteamID64()

  Cosmo.DB:getPlayerWeaponActions(sid64)
    :resolved(function(actions)
      local wepClasses = {}
      
      for _, action in pairs(actions) do
        action.data = util.JSONToTable(action.data) or {}

        if action.data.perm ~= "1" then continue end
        if not action.data.classes then continue end

        table.insert(wepClasses, action)
      end

      ply.__cosmoWeapons = wepClasses
    end)
end)