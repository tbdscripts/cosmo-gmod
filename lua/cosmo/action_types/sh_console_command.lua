local replace = string.Replace

local CONSOLE_COMMAND = Cosmo.ActionType.New("console_command")

local function replaceVariables(command, ply)
    command = replace(command, ":sid64", ply:SteamID64())
    command = replace(command, ":sid", ply:SteamID())

    -- Escape dangerous characters that could fuck up the command and potentially run multiple commands
    command = replace(command, ":nick", "\"" .. ply:Nick():gsub("[;\"']", "") .. "\"")

    return command
end

function CONSOLE_COMMAND:HandlePurchase(action, order, ply)
    local command = action.data.cmd
    if not command then return false end

    game.ConsoleCommand(replaceVariables(command, ply) .. "\n")

    return true
end

function CONSOLE_COMMAND:HandleExpiration(action, order, ply)
    local command = action.data.expire_cmd
    if not command then return false end

    game.ConsoleCommand(replaceVariables(command, ply) .. "\n")

    return true
end

Cosmo.ActionType.Register(CONSOLE_COMMAND)