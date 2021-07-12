Cosmo = Cosmo or {}
Cosmo.ActionMeta = Cosmo.ActionMeta or {}

-- Set to false on production
Cosmo.Debug = true

function Cosmo:log(...)
  local printStr = ""
  for _, str in ipairs({...}) do
    printStr = printStr .. str .. " "
  end

  print("[Cosmo]", printStr)
end

function Cosmo:logDebug(...)
  if not self.Debug then return end

  local printStr = ""
  for _, str in ipairs({...}) do
    printStr = printStr .. str .. " "
  end

  print("[Cosmo - DEBUG]", printStr)
end

function Cosmo:loadClientFile(path)
  if SERVER then
    AddCSLuaFile(path)
  else
    include(path)
  end
end

function Cosmo:loadServerFile(path)
  if not SERVER then return end
  
  include(path)
end

function Cosmo:loadSharedFile(path)
  self:loadClientFile(path)
  self:loadServerFile(path)
end

function Cosmo:loadFile(path)
  path = string.TrimRight(path, ".lua")
  path = path .. ".lua"

  local name = string.GetFileFromFilename(path)
  local realm = name:sub(1, 3)

  if realm == "cl_" then
    self:loadClientFile(path)
  elseif realm == "sv_" then
    self:loadServerFile(path)
  elseif realm == "sh_" then
    self:loadSharedFile(path)
  else
    return self:log("Invalid file realm:", name, "(" .. string.GetPathFromFilename(path) .. ")")
  end

  self:logDebug("Loaded file:", name, "(" .. string.GetPathFromFilename(path) .. ")")
end

function Cosmo:loadDirectory(dir)
  local files, dirs = file.Find(dir .. "/*", "LUA")

  self:logDebug("Loading directory:", dir, string.format("(%d files, %d directories)", #files, #dirs))

  for _, file in ipairs(files) do
    self:loadFile(dir .. "/" .. file)
  end

  for _, subDir in ipairs(dirs) do
    self:loadDirectory(dir .. "/" .. subDir)
  end
end

-- Config
Cosmo:loadFile("cosmo/config/sh_config")
Cosmo:loadFile("cosmo/config/sv_config")

-- Types
Cosmo:loadFile("cosmo/core/sh_action_type")
Cosmo:loadDirectory("cosmo/config/action_types")

Cosmo:loadDirectory("cosmo/libs")

Cosmo:loadFile("cosmo/core/sv_database")
Cosmo:loadFile("cosmo/core/sv_core")

Cosmo:loadDirectory("cosmo/network")

Cosmo:loadFile("cosmo/core/cl_notification")
