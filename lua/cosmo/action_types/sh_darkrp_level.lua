local DARKRP_LEVEL = Cosmo.ActionType.New("darkrp_level")

function DARKRP_LEVEL:HandlePurchase(action, order, ply)
    local amount = action.data.amount
    if not amount then return false end

    amount = tonumber(amount)
    if not amount then return false end

    if LevelSystemConfiguration and isfunction(ply.addLevels) then -- Vrondakis
        ply:addLevels(amount)
    elseif GlorifiedLeveling and isfunction(GlorifiedLeveling.AddPlayerLevels) then -- Glorified
        GlorifiedLeveling.AddPlayerLevels(ply, amount)
    else
        print("[Cosmo - STORE] No compatible leveling system found.")
        return false
    end

    return true
end

function DARKRP_LEVEL:HandleExpiration()
    -- NOOP

    return true
end

Cosmo.ActionType.Register(DARKRP_LEVEL)