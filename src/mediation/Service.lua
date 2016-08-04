--
-- Provides ability to fetch mediation (ad) configuration from a server.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require("HTTPResponseType")

local Error = require("Error")
local Promise = require("Promise")
local Config = require("mediation.Config")

local Service = Class()

function Service.new(self)
    local http
    local url

    function self.init(_http, _url)
        http = _http
        url = _url
    end

    function self.fetchConfig()
        Log.i("mediation.Service:fetchConfig() - Downloading mediation from (%s)", url)
        local defer = Promise()
        local promise = http.get(url, HTTPResponseType.String)
        promise.done(function(status, contents)
            local config = Config.fromJson(contents)
            defer.resolve(config)
        end)
        promise.fail(function(status, text)
            defer.reject(Error(-1, "Failed to retrieve MediationAdConfig(s) from server."))
        end)
        return defer
    end
end

return Service
