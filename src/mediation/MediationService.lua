--[[ Provides the Ad network; which provides a client interface to download Ads
    and vend them when necessary.

 @since 2015.05.27
 @copyright Upstart Illustration LLC

--]]

require "json"
require "Promise"

require "mediation.MediationConfig"
require "mediation.MediationAdConfig"

MediationService = Class()

function MediationService.new(self, host, port, path)
    self.host = host
    self.port = port
    self.path = path
    self.delegate = false -- Assign if you wish to get callbacks in regards to progress, etc.

    --[[ Download ad mediation config.

      @return Promise
    --]]
    function self.downloadConfig()
        errors = {}
        local fullpath = self.host .. self.path
        local promise = Promise()
        local request = cc.XMLHttpRequest:new()
        local function callback__complete()
            -- @todo Process data; write to disk, etc.
            if request.status < 200 or request.status > 299 then
                promise.resolve(false, nil)
            else
                local dict = json.decode(request.response)
                local ads = {}
                for _, c in ipairs(dict["ads"]) do
                    -- @fixme Should call MediationAdConfig.fromDictionary() class method from within MediationConfig.fromDictionary
                    local config = MediationAdConfig.fromDictionary(c)
                    table.insert(ads, config)
                end
                -- @fixme Should call MediationConfig.fromDictionary() class method
                local config = MediationConfig(dict["version"], ads)
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
