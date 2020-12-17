local ACTION_TYPE = {}
ACTION_TYPE.__index = ACTION_TYPE
ACTION_TYPE.registered = {}

function ACTION_TYPE.new(id)
  local self = setmetatable({}, ACTION_TYPE)
  ACTION_TYPE.registered[id] = self
  return self
end

function ACTION_TYPE.get(id)
  return ACTION_TYPE.registered[id]
end

-- Override
function ACTION_TYPE:handle(ply, data)
  return false 
end

-- Override
function ACTION_TYPE:onExpire(ply, data)
  return true
end

Cosmo.ActionType = ACTION_TYPE