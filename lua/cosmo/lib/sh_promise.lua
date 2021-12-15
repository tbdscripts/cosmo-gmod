local PROMISE = {}
PROMISE.__index = PROMISE

local PROMISE_PENDING = 0
local PROMISE_RESOLVED = 1
local PROMISE_REJECTED = 2

function PROMISE.new()
  local self = setmetatable({}, PROMISE)
  self.Status = PROMISE_PENDING
  self._Resolvers = {}
  self._Rejectors = {}
  return self
end

function PROMISE:Resolve(...)
  if self.Status ~= PROMISE_PENDING then return end

  if #self._Resolvers > 0 then
    self:_CallResolvers(...)
  else
    self._ResolveData = {...}
  end

  self.Status = PROMISE_RESOLVED
end

function PROMISE:Reject(...)
  if self.Status ~= PROMISE_PENDING then return end

  if #self._Rejectors > 0 then
    self:_CallRejetors(...)
  else
    self._RejectData = {...}
  end

  self.Status = PROMISE_REJECTED
end

function PROMISE:Then(func)
  if not isfunction(func) or self.Status == PROMISE_REJECTED then return self end

  if self.Status == PROMISE_RESOLVED then
    self:_CallResolvers(unpack(self._ResolveData))
  else
    table.insert(self._Resolvers, func)
  end

  return self
end

function PROMISE:Catch(func)
  if not isfunction(func) or self.Status == PROMISE_RESOLVED then return self end

  if self.Status == PROMISE_REJECTED then
    self:_CallRejetors(unpack(self._RejectData))
  else
    table.insert(self._Rejectors, func)
  end

  return self
end

function PROMISE:_CallResolvers(...)
  for _, func in ipairs(self._Resolvers) do
    func(...)
  end

  self._Resolvers = {}
end

function PROMISE:_CallRejetors(...)
  for _, func in ipairs(self._Rejectors) do
    func(...)
  end

  self._Rejectors = {}
end

Cosmo.Promise = PROMISE