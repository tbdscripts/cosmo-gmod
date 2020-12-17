local USERGROUP = Cosmo.ActionType.new("usergroup")

local function setUsergroup(ply, usergroup)
  if sam then
    print(ply, usergroup)
  else
    Cosmo:log("No valid admin system found.")
    return false
  end

  return true
end

function USERGROUP:handle(ply, data)
  local group = data.group
  if not group then return false end

  return setUsergroup(ply, group)
end

function USERGROUP:onExpired(ply, data)
  local expireGroup = data.expire_group
  if not expireGroup then return true end

  return setUsergroup(ply, expireGroup)
end