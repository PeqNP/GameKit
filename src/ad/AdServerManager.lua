--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Error"

local AdServerManager = Class()

function AdServerManager.new(self)
    local bridge
    local adConfig
    local networks
    local defaultAdConfig
    local service
    local deferred

    -- @param bridge.modules.ad
    -- @param MediationAdFactory
    -- @param MediationService
    function self.init(_bridge, _adConfig, _networks, _service)
        bridge = _bridge
        adConfig = _adConfig
        networks = _networks
        service = _service
    end

    function self.getAdManager(adFactory)
        Log.d("Registering %d MediationAdConfig(s) with an AdManager", #networks)
        local adManager = AdManager(bridge, adFactory)
        adManager.configure(adConfig)
        adManager.registerNetworks(networks)
        return adManager
    end

    -- @return Promise<AdManager>, fn cancel
    function self.fetchConfig()
        if not service then
            local promise = Promise()
            promise.reject(Error(500, "MediationService was not been provided."))
            return promise
        end
        if deferred then
            return deferred
        end
        deferred = Promise()
        local promise = service.downloadConfig()
        promise.done(function(success, config)
            if not success then
                deferred.reject(Error(501, "Failed to retrieve MediationAdConfig(s) from server."))
                deferred = nil
                return
            end
            local configs = config.getAds()
            Log.i("AdServerManager:fetchConfig() - Downloaded mediation network config w/ success (%s) # configs (%d)", success, #configs)
            if #configs > 0 then
                for _, c in ipairs(configs) do
                    Log.i("AdServerManager:fetchConfig() - Network (%d) impression reward (%s) click reward (%s)", c.getAdNetwork(), c.getRewardForImpression() or "", c.getRewardForClick() or "")
                end

                local factory = MediationAdFactory(configs)
                if not factory.getLastError() then
                    deferred.resolve(self.getAdManager(factory))
                else
                    deferred.reject(Error(502, factory.getLastError()))
                end
            else
                deferred.reject(Error(503, "Server has no configs."))
            end
            deferred = nil
        end)
        return deferred
    end
end

return AdServerManager
