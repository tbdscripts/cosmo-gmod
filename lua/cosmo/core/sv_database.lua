local DB = {}
DB.__index = DB

function DB.new()
  local self = setmetatable({}, DB)
  self:init()
  return self
end

function DB:init(creds)
  require("mysqloo")
  if not mysqloo then return end

  local creds = Cosmo.Config.MySQL
  local db = mysqloo.connect(creds.host, creds.username, creds.password, creds.database, creds.port)

  db.onConnected = function(db)
    self:log("Database connection successful")
  end
  db.onConnectionFailed = function(db, err)
    self:log("Database connection failed:", err)
  end

  db:connect()
  self.con = db
end

function DB:query(qs, ...)
  local args = {}
  for _, arg in ipairs({...}) do
    table.insert(args, self:escape(arg))
  end

  local sqlStr = string.format(qs, unpack(args))
  local promise = Cosmo.Promise.new()
  local query = self.con:query(sqlStr)

  query.onSuccess = function(q, data)
    promise:resolve(data)
    Cosmo:logDebug("Query executed:", sqlStr)
  end
  query.onError = function(q, err)
    promise:reject(err)
    self:log("Query Error: " .. err)
  end

  query:start()
  return promise
end

function DB:escape(qs)
  qs = tostring(qs)

  return string.format("'%s'", self.con:escape(qs))
end

function DB:getPendingActions()
  return self:query([[
    SELECT `id`, `name`, `data`, `receiver`
    FROM `actions`
    WHERE `delivered_at` IS NULL;
  ]])
end

function DB:completeAction(id)
  return self:query([[
    UPDATE `actions`
    SET `delivered_at` = CURRENT_TIMESTAMP()
    WHERE `id` = %s;
  ]], id)
end

function DB:log(msg)
  print("[Cosmo - DB] " .. msg)
end

Cosmo.DB = DB.new()