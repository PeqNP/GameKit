--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Error = require("Error")
local Promise = require("Promise")
local AdManager = require("ad.Manager")
local MediationAdFactory = require("mediation.AdFactory")

local ServerManager = Class()

function ServerManager.new(self)
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
        Log.d("Registering %d MediationAdConfig(s) with AdManager", #networks)
        local adManager = AdManager(bridge, adFactory)
        adManager.configure(adConfig)
        adManager.registerNetworks(networks)
        return adManager
    end

    -- @return Promise<AdManager>, fn cancel
    function self.fetchConfig()
        if not service then
            local promise = Promise()
            promise.reject(Error(500, "mediation.Service was not provided."))
            return promise
        end
        if deferred then
            return deferred
        end
        deferred = Promise()
        local promise = service.fetchConfig()
        promise.done(function(config)
            local configs = config.getAds()
            Log.i("ServerManager:fetchConfig() - Downloaded mediation network config w/ # configs (%d)", #configs)
            if #configs > 0 then
                for _, c in ipairs(configs) do
                    Log.i("ServerManager:fetchConfig() - Network (%d) type (%d) impression (%s) click (%s)", c.getAdNetwork(), c.getAdType(), c.getRewardForImpression() or "", c.getRewardForClick() or "")
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
        promise.fail(function(_error)
            Log.i("ServerManager:fetchConfig() - Failed to retrieve MediationAdConfig(s) from server.")
            deferred.reject(_error)
            deferred = nil
        end)
        return deferred
    end
end

return ServerManager
