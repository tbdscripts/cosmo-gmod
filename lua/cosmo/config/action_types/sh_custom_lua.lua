local CUSTOM_LUA = Cosmo.ActionType.new("custom_lua")

local function replaceStrings(code, ply)
  code = code:Replace(":sid64", ply:SteamID64())
  code = code:Replace(":sid", ply:SteamID64())
  code = code:Replace(":nick", ply:Nick():gsub("[;\"']", ""))

  return code
end

function CUSTOM_LUA:onBought(ply, data)
  local code = data.on_bought
  if not code then return false end

  RunString(replaceStrings(code, ply), "Cosmo Action")
  return true
end

function CUSTOM_LUA:onExpired(ply, data)
  local code = data.on_expired
  if not code then return false end

  RunString(replaceStrings(code, ply), "Cosmo Action")
  return true
end