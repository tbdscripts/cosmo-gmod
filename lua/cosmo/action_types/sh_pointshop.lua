local POINTSHOP = Cosmo.ActionType.New("ps_points")

function POINTSHOP:HandlePurchase(action, order, ply)
    if not isfunction(ply.PS_GivePoints) then
        Cosmo.Log.Warning("(POINTSHOP)", "No pointshop system was found on this server.")
        return false
    end
    
    local amount = action.data.amount
    if not amount then return false end

    amount = tonumber(amount)
    if not amount then return false end

    if amount < 0 and isfunction(ply.PS_TakePoints) then
        ply:PS_TakePoints(amount)
    elseif amount > 0 then
        ply:PS_GivePoints(amount)
    end

    return true
end

function POINTSHOP:HandleExpiration(action, order, ply)
    -- NOOP

    return true
end

Cosmo.ActionType.Register(POINTSHOP)