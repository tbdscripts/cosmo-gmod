local CurTime = CurTime

local nextFetch = CurTime()

hook.Add("InitPostEntity", "Cosmo.Store.Init", function()
    local baseUrl = string.TrimRight(Cosmo.Config.InstanceUrl, "/") .. "/api/game/"

    Cosmo.Http:SetBaseUrl(baseUrl)
    Cosmo.Http:SetAuthorizationToken(Cosmo.Config.ServerToken)

    nextFetch = CurTime() + Cosmo.Config.FetchInterval
end)

local function handlePendingAction(action, order, ply)
    local actionType = Cosmo.ActionType.FindByName(action.name)
    if not actionType then return false end

    if not actionType:HandlePurchase(action, order, ply) then
        return false
    end

    Cosmo.Http:DoRequest("PUT", "/store/actions/" .. action.id .. "/complete")
        :Catch(function(reason)
            print("Failed to deliver action", action.id)
        end)

    return true
end

local function handlePendingOrder(order)
    if not order.actions then return end

    local ply = player.GetBySteamID64(order.receiver)
    if not ply then return end

    local success = true

    print(#order.actions)

    for _, action in ipairs(order.actions) do
        local result = handlePendingAction(action, order, ply)
        if not result then
            success = false
        end
    end

    if not success then return end

    Cosmo.Http:DoRequest("PUT", "/store/orders/" .. order.id .. "/deliver")
        :Catch(function(reason)
            print("[Cosmo - Store] Failed to deliver order", order.id)
        end)
end

local function handleExpiredAction(action)
    local actionType = Cosmo.ActionType.FindByName(action.name)
    print(action.name)
    if not actionType then return end

    print(actionType)

    local ply = player.GetBySteamID64(action.receiver)
    if not ply then return end

    if not actionType:HandleExpiration(action, action.order, ply) then
        print("[Cosmo - STORE] Failed to handle expiration of action", action.id)
        return
    end

    Cosmo.Http:DoRequest("PUT", "/store/actions/" .. action.id .. "/expire")
        :Catch(function(reason)
            print("[Cosmo - STORE] Failed to expire action", action.id)
        end)
end

local function fetchPending()
    Cosmo.Http:DoRequest("GET", "/store/pending")
        :Then(function(data, status)
            if status ~= 200 or not data or not istable(data) then return end

            for _, order in ipairs(data.orders) do
                handlePendingOrder(order)
            end

            for _, action in ipairs(data.actions) do
                handleExpiredAction(action)
            end
        end)
        :Catch(function(reason)
            print("Failed to fetch pending from store:", reason)
        end)
end

hook.Add("Think", "Cosmo.Store.FetchPending", function()
    if not (nextFetch and nextFetch < CurTime()) then return end

    fetchPending()

    nextFetch = CurTime() + Cosmo.Config.FetchInterval
end)

hook.Add("PlayerSay", "Cosmo.DonateCommand", function(ply, text)
    if not IsValid(ply) or text ~= Cosmo.Config.DonateCommand then return end
  
    Cosmo.Network.OpenDonateCommand(ply)
end)