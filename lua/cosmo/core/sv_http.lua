local assert, isstring = assert, isstring
local trimLeft, trimRight, upper = string.TrimLeft, string.TrimRight, string.upper
local startsWith = string.StartWith
local mergeTable = table.Merge

local function checkInstalled(module)
    if BRANCH ~= "unknown" then return true end -- util.IsBinaryModuleInstalled is currently only on the main/dev branches. Thanks rubat

    return util.IsBinaryModuleInstalled(module) or false
end

local httpFunc = HTTP
if checkInstalled("reqwest") and isfunction(reqwest) then
    pcall(require, "reqwest")
    httpFunc = reqwest
elseif checkInstalled("chttp") and isfunction(CHTTP) then
    pcall(require, "chttp")
    httpFunc = CHTTP
else
    Cosmo.Log.Warning("Reqwest or CHTTP not found! It is reccomended to install one of these modules.")
    Cosmo.Log.Warning("https://docs.tbdscripts.com/docs/installation/garrys-mod#installing-a-http-module")
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
