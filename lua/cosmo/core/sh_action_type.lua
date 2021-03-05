local ACTION_TYPE = {}
ACTION_TYPE.__index = ACTION_TYPE
ACTION_TYPE.registered = {}

function ACTION_TYPE.new(id)
  local self = setmetatable({}, ACTION_TYPE)
  self:setId(id)

  ACTION_TYPE.registered[id] = self
  return self
end

function ACTION_TYPE.get(id)
  return ACTION_TYPE.registered[id]
end

function ACTION_TYPE:getId()
  return self.id
end

function ACTION_TYPE:setId(id)
  self.id = id
end

-- Override
function ACTION_TYPE:onBought(ply, data)
  return false 
end

-- Override
function ACTION_TYPE:onExpire(ply, data)
  return true
end

function ACTION_TYPE:IsValid()
  return ACTION_TYPE.registered[self:getId()] ~= nil
end

function ACTION_TYPE:addHook(hookName, func)
  hook.Add(hookName, self, function(_, ...)
    func(...)
  end)
end

Cosmo.ActionType = ACTION_TYPE