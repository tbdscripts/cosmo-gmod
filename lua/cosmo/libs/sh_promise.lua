local PROMISE = {}
PROMISE.__index = PROMISE

local PROMISE_PENDING = 0
local PROMISE_RESOLVED = 1
local PROMISE_REJECTED = 2

function PROMISE.new()
  local self = setmetatable({}, PROMISE)
  self.status = PROMISE_PENDING
  self.resolvers = {}
  self.rejectors = {}
  return self
end

function PROMISE:resolve(...)
  if self.status ~= PROMISE_PENDING then return end

  if #self.resolvers > 0 then
    self:callResolvers(...)
  else
    self.resolveData = {...}
  end

  self.status = PROMISE_RESOLVED
end

function PROMISE:reject(...)
  if self.status ~= PROMISE_PENDING then return end

  if #self.rejectors > 0 then
    self:callRejectors(...)
  else
    self.rejectData = {...}
  end

  self.status = PROMISE_REJECTED
end

function PROMISE:resolved(func)
  if not isfunction(func) or self.status == PROMISE_REJECTED then return end

  if self.status == PROMISE_RESOLVED then
    self:callResolvers(unpack(self.resolveData))
  else
    table.insert(self.resolvers, func)
  end
end

function PROMISE:rejected(func)
  if not isfunction(func) or self.status == PROMISE_RESOLVED then return end

  if self.status == PROMISE_REJECTED then
    self:callRejectors(unpack(self.rejectData))
  else
    table.insert(self.rejectors, func)
  end
end

function PROMISE:callResolvers(...)
  for _, func in ipairs(self.resolvers) do
    func(...)
  end

  self.resolvers = {}
end

function PROMISE:callRejectors(...)
  for _, func in ipairs(self.rejectors) do
    func(...)
  end

  self.rejectors = {}
end

Cosmo.Promise = PROMISE