--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

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
    function self.init(_bridge, _adConfig, _networks, _defaultAdConfig, _service)
        bridge = _bridge
        adConfig = _adConfig
        networks = _networks
        defaultAdConfig = _defaultAdConfig
        service = _service
    end

    local function getAdManager(adFactory)
        Log.d("Registering %d networks with the Ad Manager", #networks)
        local adManager = AdManager(bridge, adFactory)
        adManager.configure(adConfig)
        adManager.registerNetworks(networks)
        return adManager
    end

    local function getDefaultAdManager()
        if not defaultAdConfig then
            return nil
        end
        local adFactory = MediationAdFactory(defaultAdConfig.getAds())
        return getAdManager(adFactory)
    end

    -- @return Promise<AdManager>, fn cancel
    function self.fetchConfig()
        if not service then
            local promise = Promise()
            promise.resolve(getDefaultAdManager())
            return promise
        end
        if deferred then
            return deferred
        end
        deferred = Promise()
        local promise = service.downloadConfig()
        promise.done(function(success, config)
            if not success then
                Log.e("AdServerManager:fetchConfig() - Failed to retrieve MediationAdConfig(s) from server. Returning default.")
                deferred.resolve(getDefaultAdManager())
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
                    deferred.resolve(getAdManager(factory))
                else
                    Log.e("Mediation config has error (%s)", factory.getLastError().getMessage())
                    deferred.resolve(getDefaultAdManager())
                end
            else
                Log.w("AdServerManager:fetchConfig() - Server has no configs!")
                deferred.resolve(getDefaultAdManager())
            end
            deferred = nil
        end)
        return deferred
    end
end

return AdServerManager
