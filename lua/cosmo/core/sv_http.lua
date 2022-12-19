local assert, isstring = assert, isstring
local trimLeft, trimRight, upper = string.TrimLeft, string.TrimRight, string.upper
local startsWith = string.StartWith
local mergeTable = table.Merge

local httpFunc = HTTP
if pcall(require, "reqwest") and isfunction(reqwest) then
    httpFunc = reqwest
elseif pcall(require, "chttp") and isfunction(CHTTP) then
    httpFunc = CHTTP
end

local HTTP_CLIENT = {}
HTTP_CLIENT.__index = HTTP_CLIENT

function HTTP_CLIENT.new()
    return setmetatable({
        Defaults = {
            Headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json"
            }
        }
    }, HTTP_CLIENT)
end

function HTTP_CLIENT:SetBaseUrl(baseUrl)
    assert(isstring(baseUrl), "Base URL must be a string")

    self.Defaults.BaseUrl = trimRight(baseUrl, "/")
end

function HTTP_CLIENT:SetAuthorizationToken(token)
    assert(isstring(token), "Authorization token must be a string")

    self.Defaults.Headers["Authorization"] = "Bearer " .. token
end

function HTTP_CLIENT:DoRequest(verb, endpoint, data, headers)
    verb = upper(verb)
    headers = mergeTable(headers or {}, self.Defaults.Headers)

    if data and headers["Content-Type"] == "application/json" then
        data = util.TableToJSON(data)
    end

    local url = (self.Defaults.BaseUrl or "") .. "/" .. trimLeft(endpoint, "/")
    local promise = Cosmo.Promise.new()

    httpFunc({
        method = verb,
        url = url,
        headers = headers,
        body = data,
        type = headers["Content-Type"],

        failed = function(err, errExt)
            Cosmo.Log.Danger("(HTTP)", "Request failed with reason: " .. err .. (errExt and ("(" .. errExt .. ")") or ""))
            Cosmo.Log.Danger("Endpoint:", url)

            promise:Reject(reason)
        end,

        success = function(code, body, headers)
            Cosmo.Log.Debug("(HTTP)", "Request succeeded, status code:", code)
            Cosmo.Log.Debug("Endpoint:", url)

            -- It seems like reqwest makes header names lowercase.
            local contentType = headers["Content-Type"] or headers["content-type"]

            if body and startsWith(contentType, "application/json") then
                body = util.JSONToTable(body)
            end

            promise:Resolve(body, code, headers)
        end,
    })

    return promise
end

Cosmo.Http = Cosmo.Http or HTTP_CLIENT.new()
