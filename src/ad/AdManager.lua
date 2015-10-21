--[[ Provides interface to display ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

require("Logger")
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
    local private = {}

    function private.getNetworkModule(adNetwork, adType)
        for _, module in ipairs(networkModules) do
            if module.getAdNetwork() == adNetwork and module.getAdType() == adType then
                return module
            end
        end
        return nil
    end

    function private.cacheModules(modules)
        for _, module in ipairs(modules) do
            private.cacheModule(module)
        end
    end

    function private.rebuildRequests()
        local modules = {}
        local incomplete = {}
        for pos, request in ipairs(requests) do
            if request.isComplete() then
                -- @fixme Hmm... should the request have a reference to its respective AdModule?
                -- Should the module maintain its current request?
                local adNetwork = request.getAdNetwork() 
                local adType = request.getAdType()
                local module = private.getNetworkModule(adNetwork, adType)
                if module then
                    table.insert(modules, module)
                else
                    Log.e("Could not find module for ad network (%s) ad type (%s)", adNetwork, adType)
                end
            else
                table.insert(incomplete, request)
            end
        end

        requests = incomplete

        private.cacheModules(modules)
    end

    function private.cacheModule(module)
        local request = module.generateAdRequest()
        table.insert(requests, request)
        request.setState(AdState.Loading)

        local promise = adaptor.cache(request)
        promise.done(function(response)
            request.setState(response.getState())
        end)
        promise.fail(function(response)
            request.setState(response.getState())
            _error = response.getError()
            cu.delayCall(private.rebuildRequests, TIMEOUT[2])
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
        private.cacheModule(module)
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
                request.setState(AdState.Presenting)
                promise.done(function(response)
                    request.setState(response.getState())
                end)
                promise.fail(function(response)
                    request.setState(AdState.Complete)
                    _error = response.getError()
                end)
                promise.always(function(response)
                    cu.delayCall(private.rebuildRequests, TIMEOUT[2])
                end)
                return promise
            end
        end
        return nil
    end

    function self.getError()
        return _error
    end
end
