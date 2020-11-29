local ACTION_TYPE = {}
ACTION_TYPE.__index = ACTION_TYPE
ACTION_TYPE.registered = {}

print('loaded')

function ACTION_TYPE.new(id)
  local self = setmetatable({}, ACTION_TYPE)
  ACTION_TYPE.registered[id] = self
  return self
end

function ACTION_TYPE.get(id)
  return ACTION_TYPE.registered[id]
end

function ACTION_TYPE:handle(ply, data)
  -- Override
  return false 
end

Cosmo.ActionType = ACTION_TYPE