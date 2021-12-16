local replace = string.Replace

local CUSTOM_LUA = Cosmo.ActionType.New("custom_lua")

local function replaceVariables(code, ply)
    code = replace(code, ":sid64", ply:SteamID64())
    code = replace(code, ":sid", ply:SteamID())

    -- Adding nick to here felt too dangerous

    return code
end

local function setTemporaryGlobals(ply)
    Cosmo.Temp = Cosmo.Temp or {}
    Cosmo.Temp.Player = ply
end

local function clearTemporaryGlobals()
    Cosmo.Temp = nil
end

function CUSTOM_LUA:HandlePurchase(action, order, ply)
    local code = action.data.on_bought
    if not code then return false end

    setTemporaryGlobals(ply)

    local err = RunString(replaceVariables(code, ply), "Cosmo Action", false)
    if err then
        Cosmo.Log.Warning("(CUSTOM-LUA) Failed to run custom lua, reason:", err)
    end
    
    clearTemporaryGlobals()

    return true
end

function CUSTOM_LUA:HandleExpiration(action, order, ply)
    local code = action.data.on_expired
    if not code then return end

    setTemporaryGlobals(ply)

    local err = RunString(replaceVariables(code, ply), "Cosmo Action Expiration", false)
    if err then
        Cosmo.Log.Warning("(CUSTOM-LUA) Failed to run custom lua, reason:", err)
    end

    clearTemporaryGlobals()

    return true
end

Cosmo.ActionType.Register(CUSTOM_LUA)