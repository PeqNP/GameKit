--[[ Provides interface to display ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

require("Promise")
require("ad.Constants")

AdManager = Class()

-- Graduated timeout intervals.
local TIMEOUT = {15, 30, 60, 120, 240, 600}

function AdManager.new(self, adaptor, config)
    local delegate
    local networkModules = {}
    local _error
    local requests = {}

    local function cache(module)
        local request = module.generateAdRequest()
        table.insert(requests, request)
        request.setState(AdState.Loading)

        local promise = adaptor.cache(request)
        promise.done(function(response)
            request.setState(AdState.Ready)
        end)
        promise.fail(function(response)
            request.setState(AdState.Complete)
            _error = response.getError()
            cu.delayCall(TIMEOUT[2], cache)
        end)
    end

    function self.getConfig()
        return config
    end

    function self.setDelegate(d)
        delegate = d
    end

    function self.getDelegate()
        return delegate
    end

    function self.getRequests()
        return requests
    end

    --
    -- Register a mediation network w/ provided config.
    -- Starts the process of caching the module.
    -- 
    -- @param AdNetworkModule
    -- 
    function self.registerNetworkModule(module)
        table.insert(networkModules, module)
        cache(module)
    end

    -- @return AdNetworkModule[]
    function self.getRegisteredNetworkModules()
        return networkModules
    end

    --
    -- @param AdType
    --
    -- @return boolean - true when an ad type is ready for presenting.
    --
    function self.isAdAvailable(adType)
        for _, request in ipairs(requests) do
            if request.getAdType() == adType and request.getState() == AdState.Ready then
                return true
            end
        end
        return false
    end

    --
    -- Show an ad type.
    --
    -- @param AdType
    --
    -- @return boolean - true when a message is sent to native land to show the ad.
    --
    function self.showAd(adType)
        -- @todo Ask the MediationManager to give us the next ad that should be displayed
        -- for the given type.
        for _, request in ipairs(requests) do
            if request.getAdType() == adType and request.getState() == AdState.Ready then
                local promise = adaptor.show(request)
                promise.done(function(response)
                    request.setState(AdState.Presenting)
                end)
                promise.fail(function(response)
                    request.setState(AdState.Complete)
                    _error = response.getError()
                end)
                return true
            end
        end
        return false
    end

    function self.getError()
        return _error
    end
end
