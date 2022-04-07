local PULSAR = Cosmo.ActionType.New("pulsar")

function PULSAR:HandlePurchase(action, order, ply)
    local amount = action.data.amount
    if not amount then return false end

    amount = tonumber(amount)
    if not amount then return false end

    if not Lyth_Pulsar then
        Cosmo.Log.Warning("Pulsar is not installed, failed to handle purchase.")
        return false
    end

    local res, err = pcall(Lyth_Pulsar.DB.GiveCredits, nil, ply, amount)
    if not res then
        Cosmo.Log.Danger("Failed to give credits to user!")
        Cosmo.Log.Danger(err)

        return false
    end

    return true
end

function PULSAR:HandleExpiration()
    -- NOOP

    return true
end

Cosmo.ActionType.Register(PULSAR)