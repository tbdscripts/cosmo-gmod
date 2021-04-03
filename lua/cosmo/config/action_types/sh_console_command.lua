local CONCOMMAND = Cosmo.ActionType.new("console_command")

local function replaceStrings(cmd, ply)
  cmd = cmd:Replace(":sid64", ply:SteamID64())
  cmd = cmd:Replace(":sid", ply:SteamID64())
  cmd = cmd:Replace(":nick", ply:Nick())

  return cmd
end

function CONCOMMAND:onBought(ply, data)
  local cmd = data.cmd
  if not cmd then return false end

  game.ConsoleCommand(replaceStrings(cmd, ply) .. "\n")
  return true
end

function CONCOMMAND:onExpired(ply, data)
  local cmd = data.expire_cmd
  if not cmd then return false end

  game.ConsoleCommand(replaceStrings(cmd, ply))
  return true
end