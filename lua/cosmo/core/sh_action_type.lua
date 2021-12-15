local ACTION_TYPE = {}
ACTION_TYPE.__index = ACTION_TYPE

ACTION_TYPE._Registered = {}

function ACTION_TYPE.New(name)
    assert(isstring(name), "Action type name must be provided")

    local inst = setmetatable({}, ACTION_TYPE)
    inst.Name = name
    return inst
end

function ACTION_TYPE.Register(inst)
    assert(getmetatable(inst) == ACTION_TYPE, "Parameter 'inst' must be of type ACTION_TYPE")

    ACTION_TYPE._Registered[inst.Name] = inst
end

function ACTION_TYPE.FindByName(name)
    return ACTION_TYPE._Registered[name]
end

function ACTION_TYPE:HandlePurchase(action, order, ply)
    Error("Action Type '", self.Name, "' has no HandlePurchase override!")

    return false
end

function ACTION_TYPE:HandleExpiration(action, order, ply)
    Error("Action Type '", self.Name, "' has no HandleExpiration override!")

    return false
end

Cosmo.ActionType = ACTION_TYPE