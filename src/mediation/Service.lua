--
-- Provides the Ad network; which provides a client interface to download
-- a JSON format of MediationAdConfig[].
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local Promise = require("Promise")
local Config = require("mediation.Config")

local Service = Class()

function Service.new(self)
    self.delegate = false -- Assign if you wish to get callbacks in regards to progress, etc.

    function self.init(host, port, path)
        self.host = host
        self.port = port
        self.path = path
    end

    --[[ Download ad mediation config.

      @return Promise
    --]]
    function self.downloadConfig()
        local fullpath
        if self.port then
            fullpath = string.format("%s:%s%s", self.host, self.port, self.path)
        else
            fullpath = self.host .. self.path
        end
        Log.i("mediation.Service:downloadConfig() - Downloading mediation from (%s)", fullpath)

        errors = {}
        local promise = Promise()
        local request = cc.XMLHttpRequest:new()
        local function callback__complete()
            -- @todo Process data; write to disk, etc.
            if request.status < 200 or request.status > 299 then
                promise.resolve(false, nil)
            else
                local config = Config.fromJson(request.response)
                promise.resolve(true, config)
            end
        end
        request.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        request:registerScriptHandler(callback__complete)
        request:open("GET", fullpath, true)
        request:send()
        return promise
    end
end

return Service
