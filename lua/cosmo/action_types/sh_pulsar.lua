local PULSAR = Cosmo.ActionType.New("pulsar")

function PULSAR:HandlePurchase(action, order, ply)
    local amount = action.data.amount
    if not amount then return false end

    amount = tonumber(amount)
    if not amount then return false end

    if Lyth_Pulsar then
        local res, err = pcall(Lyth_Pulsar.DB.GiveCredits, nil, ply, amount)
        if not res then
            Cosmo.Log.Danger("(PULSAR)", "Failed to give Pulsar Store 1 credits to user, reason: " .. err)
    
            return false
        end
    elseif PulsarStore then
        local res, err = pcall(PulsarStore.API.GiveUserCredits, ply:SteamID64(), amount)
        if not res then
            Cosmo.Log.Danger("(PULSAR)", "Failed to give Pulsar Store 2 credits to user, reason: " .. err)
    
            return false
        end
    else
        Cosmo.Log.Danger("(PUSLAR)", "Pulsar Store 1 or 2 is not installed, failed to handle purchase.")
        return false
    end

    return true
end

function PULSAR:HandleExpiration()
    -- NOOP

    return true
end

Cosmo.ActionType.Register(PULSAR)