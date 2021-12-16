local format, concat = string.format, table.concat

local LOG = {}
LOG.__index = LOG

setmetatable(LOG, {
    __call = function(_, level, ...)
        LOG._InternalLog(level, ...)
    end
})

LOG.LEVEL_DEBUG = 1
LOG.LEVEL_INFO = 2
LOG.LEVEL_WARNING = 3
LOG.LEVEL_DANGER = 4

local logLevels = {
    [LOG.LEVEL_DEBUG] = {
        name = "DEBUG",
    },
    [LOG.LEVEL_INFO] = {
        name = "INFO",
    },
    [LOG.LEVEL_WARNING] = {
        name = "WARNING",
    },
    [LOG.LEVEL_DANGER] = {
        name = "DANGER",
    },
}

function LOG._InternalLog(level, ...)
    local logLevel = Cosmo.Config.LogLevel or LOG.LEVEL_INFO
    if level < logLevel then return end -- Log level disabled

    local levelData = logLevels[level]
    if not levelData then return end -- Invalid log level

    print(
        format("[Cosmo ~ %s] %s", levelData.name, concat({...}, " "))
    )
end

function LOG.Debug(...)
    LOG(LOG.LEVEL_DEBUG, ...)
end

function LOG.Info(...)
    LOG(LOG.LEVEL_INFO, ...)
end

function LOG.Warning(...)
    LOG(LOG.LEVEL_WARNING, ...)
end

function LOG.Danger(...)
    LOG(LOG.LEVEL_DANGER, ...)
end

Cosmo.Log = LOG