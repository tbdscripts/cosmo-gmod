-- http://pointshop2.kamshak.com/en/latest/api/index.html#player-integration

-- Standard Points

local PS2_STANDARD_POINTS = Cosmo.ActionType.New("ps2_standard_points")

function PS2_STANDARD_POINTS:HandlePurchased(action, order, ply)
    if not isfunction(ply.PS2_AddStandardPoints) then 
        Cosmo.Log.Warning("(POINTSHOP2)", "No pointshop system was found on this server")
        return false
    end

    local amount = action.data.amount
    if not amount then return false end

    amount = tonumber(amount)
    if not amount then return false end

    ply:PS2_AddStandardPoints(amount)
    return true
end

function PS2_STANDARD_POINTS:HandleExpiration()
    -- NOOP

    return true
end

Cosmo.ActionType.Register(PS2_STANDARD_POINTS)

-- Premium Points

local PS2_PREMIUM_POINTS = Cosmo.ActionType.New("ps2_premium_points")

function PS2_PREMIUM_POINTS:HandlePurchased()
    if not isfunction(ply.PS2_AddPremiumPoints) then 
        Cosmo.Log.Warning("(POINTSHOP2)", "No pointshop system was found on this server")
        return false
    end

    local amount = action.data.amount
    if not amount then return false end

    amount = tonumber(amount)
    if not amount then return false end

    ply:PS2_AddPremiumPoints(amount)
    return true
end

function PS2_PREMIUM_POINTS:HandleExpiration()
    -- NOOP

    return true
end

Cosmo.ActionType.Register(PS2_PREMIUM_POINTS)