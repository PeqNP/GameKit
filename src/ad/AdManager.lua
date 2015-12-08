--[[ Provides interface to display ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

require("Logger")
require("Promise")
require("ad.Constants")
require("ad.AdRequest")
require("ad.AdError")

AdManager = Class()

-- Graduated timeout intervals.
local TIMEOUT = {15, 30, 60, 120, 240, 600}

function AdManager.new(self)
    local adaptor
    local adFactory
    local delegate
    local ads = {}
    local _error
    local requests = {}
    local private = {}
    --local cachedNextAd

    function self.init(_adaptor, _adFactory)
        adaptor = _adaptor
        adFactory = _adFactory
    end

    -- Prevents the delay from being called more than once.
    local delayInProgress = false
    function private.delayRebuildRequests()
        if delayInProgress then
            return
        end
        delayInProgress = true
        cu.delayCall(private.rebuildRequests, TIMEOUT[2])
    end

    function private.cacheAds(ads)
        for _, ad in ipairs(ads) do
            private.cacheAd(ad)
        end
    end

    function private.rebuildRequests()
        delayInProgress = false

        local ads = {}
        local incomplete = {}
        for pos, request in ipairs(requests) do
            if request.isComplete() then
                local ad = request.getAd()
                table.insert(ads, ad)
            else
                table.insert(incomplete, request)
            end
        end

        requests = incomplete

        private.cacheAds(ads)
    end

    function private.cacheAd(ad)
        local request = AdRequest(ad)
        request.setState(AdState.Loading)
        local response, promise = adaptor.cache(request)

        if not response.success then
            private.delayRebuildRequests()
            return
        end

        table.insert(requests, request)
        promise.done(function(response)
            request.setState(AdState.Ready)
        end)
        promise.fail(function(response)
            request.setState(AdState.Complete)
            _error = response.getError()
            private.delayRebuildRequests()
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

    function self.registerNetworks(networks)
        for _, network in ipairs(networks) do
            self.registerNetwork(network)
        end
    end

    function self.registerNetwork(network)
        local response = adaptor.register(network)
        if not response.isSuccess() then
            return false, AdError(100, string.format("Failed to register the %s network", network.getName()), response.getError())
        end
        -- Map token to respective ad.
        local ads = network.getAds()
        for i, token in ipairs(response.getTokens()) do
            local ad = ads[i]
            ad.setToken(token)
            self.registerAd(ad)
        end
        return true
    end

    --
    -- Register an ad. Starts the process of caching the ad.
    -- 
    -- @param Ad
    -- 
    function self.registerAd(ad)
        table.insert(ads, ad)
        private.cacheAd(ad)
    end

    -- @return AdNetworkad[]
    function self.getRegisteredAds()
        return ads
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

    function private.getAdRequestsForType(adType)
        local _requests = {}
        for _, request in ipairs(requests) do
            if request.getAdType() == adType then
                table.insert(_requests, request)
            end
        end
        return _requests
    end

    function private.showAdForRequest(request)
        local response, promise = adaptor.show(request)
        request.setState(AdState.Presenting)
        promise.done(function(response)
            request.setState(AdState.Complete)
        end)
        promise.fail(function(response)
            request.setState(AdState.Complete)
            _error = response.getError()
        end)
        promise.always(function(response)
            private.delayRebuildRequests()
        end)
        return promise
    end

    function private.getFirstAvailableAdRequest(_requests)
        for _, request in ipairs(_requests) do
            if request.getState() == AdState.Ready then
                return request
            end
        end
        return nil
    end

    -- Returns the respective AdRequest, for the given Ad, if the request
    -- is ready to show.
    function private.getAdRequestForAd(ad, _requests)
        for _, request in ipairs(_requests) do
            if request.getAdNetwork() == ad.getAdNetwork() and request.getState() == AdState.Ready then
                return request
            end
        end
        return nil
    end

    function self.getNextAdRequest(adType)
        local _requests = private.getAdRequestsForType(adType)
        if not adFactory then
            return private.getFirstAvailableAdRequest(_requests)
        end
        -- Attempt to get the previously cached ad type until we can show it?
        --local nextAd = cachedNextAd and cachedNextAd or adFactory.nextAd(adType)
        local nextAd = adFactory.nextAd(adType)
        if nextAd then
            local request = private.getAdRequestForAd(nextAd, _requests)
            if request then -- No ad reqeusts, for this given ad type, are available.
                --cachedNextAd = nil
                return request
            end
        end
        return private.getFirstAvailableAdRequest(_requests)
    end

    function self.showAdRequest(request)
        if request then
            return private.showAdForRequest(request)
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
        local request = self.getNextAdRequest(adType)
        return self.showAdRequest(request)
    end

    function self.getError()
        return _error
    end
end
