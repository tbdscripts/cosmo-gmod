local USERGROUP = Cosmo.ActionType.new("usergroup")

local function setUsergroup(ply, usergroup)
  if sam then
    sam.player.set_rank(ply, usergroup)
  elseif xAdmin then
    xAdmin.SetGroup(ply, usergroup)
  elseif ulx and ULib then
    ply:SetUserGroup(usergroup)
  else
    Cosmo:log("No supported admin system found.")
    return false
  end

  return true
end

function USERGROUP:onBought(ply, data)
  local group = data.group
  if not group then return false end

  return setUsergroup(ply, group)
end

function USERGROUP:onExpired(ply, data)
  local expireGroup = data.expire_group
  if not expireGroup then return true end

  return setUsergroup(ply, expireGroup)
end