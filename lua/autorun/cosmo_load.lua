local trimRight, getFileFromFilename, substr, getPathFromFilename, format = string.TrimRight, string.GetFileFromFilename, string.sub, string.GetPathFromFilename, string.format

Cosmo = Cosmo or {}

function Cosmo.LoadFile(path)
    path = trimRight(path, ".lua") .. ".lua"

    local name = getFileFromFilename(path)
    local realm = substr(name, 1, 3)

    if realm == "cl_" then
        if CLIENT then
            include(path)
        else
            AddCSLuaFile(path)
        end
    elseif realm == "sh_" then
        if SERVER then
            AddCSLuaFile(path)
        end

        include(path)
    elseif realm == "sv_" then
        if SERVER then
            include(path)
        end        
    else
        print("[Cosmo] Invalid file realm:", name, "(" .. getPathFromFilename(path) .. ")")
        return
    end
end

function Cosmo.LoadDirectory(dir)
    local files, dirs = file.Find(dir .. "/*", "LUA")

    for i = 1, #files do
        Cosmo.LoadFile(dir .. "/" .. files[i])
    end

    for i = 1, #dirs do
        Cosmo.LoadDirectory(dir .. "/", dirs[i])
    end
end

Cosmo.LoadFile("cosmo/lib/sh_log.lua")

Cosmo.LoadFile("cosmo/sh_config.lua")
Cosmo.LoadFile("cosmo/sv_config.lua")

Cosmo.LoadFile("cosmo/lib/sh_promise.lua")
Cosmo.LoadFile("cosmo/lib/cl_shadows.lua")

Cosmo.LoadFile("cosmo/core/sh_action_type.lua")
Cosmo.LoadDirectory("cosmo/action_types")

Cosmo.LoadFile("cosmo/core/sv_http.lua")
Cosmo.LoadFile("cosmo/core/sv_store.lua")

Cosmo.LoadFile("cosmo/network/sv_network.lua")
Cosmo.LoadFile("cosmo/network/cl_network.lua")

Cosmo.LoadFile("cosmo/ui/cl_notification.lua")

Cosmo.Log.Info("Cosmo loaded successfully")