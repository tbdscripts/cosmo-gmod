local USERGROUP = Cosmo.ActionType.new("usergroup")

function USERGROUP:handle(ply, data)
  local group = data.group
  if not group then return false end

  if sam then
    
  else
    Cosmo:log("No valid admin system found.")
    return false
  end
end