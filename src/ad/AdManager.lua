--[[ Provides interface to display ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

require("Logger")
require("Promise")
require("ad.Constants")
require("ad.AdRequest")

AdManager = Class()

-- Graduated timeout intervals.
local TIMEOUT = {15, 30, 60, 120, 240, 600}

function AdManager.new(self)
    local adaptor
    local adFactory
    local delegate
    local networkModules = {}
    local _error
    local requests = {}
    local private = {}

    function self.init(_adaptor, _adFactory)
        adaptor = _adaptor
        adFactory = _adFactory
    end

    -- @edge Ensure network modules have unique network/ad type combination. It make no sense
    -- to have a module of the same type.

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
                local module = request.getAdModule()
                table.insert(modules, module)
            else
                table.insert(incomplete, request)
            end
        end

        requests = incomplete

        private.cacheModules(modules)
    end

    function private.cacheModule(module)
        local request = AdRequest(module)
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

    function self.getAdFactory()
        return adFactory
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
    -- Register a network service module.
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

    function private.getRequestsForType(adType)
        local _requests = {}
        for _, request in ipairs(requests) do
            if request.getAdType() == adType then
                table.insert(_requests, request)
            end
        end
        return _requests
    end

    function private.showAdForRequest(request)
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

    function private.showFirstAvailableAd(adType, _requests)
        for _, request in ipairs(_requests) do
            if request.getState() == AdState.Ready then
                return private.showAdForRequest(request)
            end
        end
        return nil
    end

    --
    -- Show an ad type.
    --
    -- @param AdType
    --
    -- @return boolean - true when a message is sent to native land to show the ad.
    --
    function self.showAd(adType)
        local _requests = private.getRequestsForType(adType)
        if not adFactory then
            return private.showFirstAvailableAd(adType, _requests)
        end
        local nextAd = adFactory.nextAd(adType)
        if nextAd then
            -- Show the request for this specific network.
            for _, request in ipairs(_requests) do
                if request.getAdNetwork() == nextAd.getAdNetwork() and request.getState() == AdState.Ready then
                    return private.showAdForRequest(request)
                end
            end
        end
        return private.showFirstAvailableAd(adType, _requests)
    end

    function self.getError()
        return _error
    end
end
