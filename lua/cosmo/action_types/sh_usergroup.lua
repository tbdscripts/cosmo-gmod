local USERGROUP = Cosmo.ActionType.New("usergroup")

local function setUsergroup(ply, group)
    if sam then -- SAM
        ply:sam_set_rank(group)
    elseif xAdmin then -- xAdmin from xNator
        xAdmin.SetGroup(ply, group)
    elseif (ulx and ULib) or (xAdmin and xAdmin.Github) then -- ULX and xAdmin from Owain
        ply:SetUserGroup(group)
    else
        Cosmo.Log.Warning("(USERGROUPS)", "No supported admin mod found, supported admind mods are: SAM, xAdmin and ULX")
        return false
    end

    return true
end

function USERGROUP:HandlePurchase(action, order, ply)
    local group = action.data.group
    if not group then return false end

    return setUsergroup(ply, group)
end

function USERGROUP:HandleExpiration(action, order, ply)
    local group = action.data.expire_group
    if not group then return false end

    return setUsergroup(ply, group)
end

Cosmo.ActionType.Register(USERGROUP)