local DARKRP_MONEY = Cosmo.ActionType.New("darkrp_money")

function DARKRP_MONEY:HandlePurchase(action, order, ply)
    if not DarkRP or not action.data.amount then return false end

    local amount = tonumber(action.data.amount)
    if not amount then return false end

    ply:addMoney(amount)
    return true
end

function DARKRP_MONEY:HandleExpiration(action, order, ply)
    -- NOOP

    return true
end

Cosmo.ActionType.Register(DARKRP_MONEY)