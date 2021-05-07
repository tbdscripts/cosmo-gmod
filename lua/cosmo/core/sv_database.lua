local DB = {}
DB.__index = DB

function DB.new()
  local self = setmetatable({}, DB)
  self:init()
  return self
end

function DB:init(creds)
  if not pcall(require, "mysqloo") then
    self:log("MySQLoo module is not installed, Cosmo requires this to be installed!")
    return
  end

  local creds = Cosmo.Config.MySQL
  local db = mysqloo.connect(creds.host, creds.username, creds.password, creds.database, creds.port)

  db.onConnected = function(db)
    self:log("Database connection successful")

    hook.Run("Cosmo.DatabaseConnected")
  end
  db.onConnectionFailed = function(db, err)
    self:log("Database connection failed: " .. err)
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
    --Cosmo:logDebug("Query executed:", sqlStr)
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

function DB:getPendingOrders()
  return self:query([[
    SELECT o.id, o.receiver, p.name AS `package_name`
    FROM orders o
      INNER JOIN packages p on o.package_id = p.id
    WHERE o.status = 'waiting_for_package'
      AND %s IN (SELECT packageable_id
                  FROM packageables pkg
                  WHERE packageable_type = 'App\\Models\\Index\\Server'
                  AND o.package_id = pkg.package_id);
  ]], Cosmo.Config.ServerId)
end

function DB:getPendingOrderActions(orderId)
  return self:query([[
    SELECT `id`, `name`, `data`, `receiver`
    FROM `actions`
    WHERE `delivered_at` IS NULL AND `order_id` = %s AND `active` = FALSE;
  ]], orderId)
end

function DB:completeAction(id)
  return self:query([[
    UPDATE `actions`
    SET `delivered_at` = CURRENT_TIMESTAMP(), `active` = TRUE
    WHERE `id` = %s;
  ]], id)
end

function DB:deliverOrder(id)
  return self:query([[
    UPDATE `orders`
    SET `status` = 'delivered'
    WHERE `id` = %s
  ]], id)
end

function DB:getExpiredActions()
  return self:query([[
    SELECT a.id, a.name, a.receiver, a.data
    FROM `actions` a
      INNER JOIN orders o on a.order_id = o.id
    WHERE `expires_at` < CURRENT_TIMESTAMP
      AND `active` = TRUE
      AND %s IN (SELECT packageable_id
                  FROM packageables pkg
                  WHERE packageable_type = 'App\\Models\\Index\\Server'
                  AND o.package_id = pkg.package_id);
  ]], Cosmo.Config.ServerId)
end

function DB:expireAction(id)
  return self:query([[
    UPDATE `actions`
    SET `active` = FALSE
    WHERE `id` = %s;
  ]], id)
end

function DB:getPlayerWeaponActions(sid64)
  return self:query([[
    SELECT `id`, `data`
    FROM `actions`
    WHERE `receiver` = %s AND `active` = TRUE AND `name` = 'weapons'
  ]], sid64)
end

function DB:log(msg)
  print("[Cosmo - DB] " .. msg)
end

Cosmo.DB = DB.new()