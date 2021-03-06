--
-- Provides interface to display ads.
--
--  @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

local shim = require("shim.System")
local App = require("shim.App")

local Promise = require("Promise")
local Error = require("Error")

require("ad.Constants")
local AdRequest = require("ad.request.AdRequest")
local AdConfigureRequest = require("ad.request.AdConfigureRequest")
local AdRegisterNetworkRequest = require("ad.request.AdRegisterNetworkRequest")

local Manager = Class()

-- Graduated timeout intervals.
local TIMEOUT = {15, 30, 60, 120, 240, 600}
local SHORT_TIMEOUT = 1.0

function Manager.new(self)
    local adaptor
    local adFactory
    local ads = {}
    local _error
    local requests = {}
    local private = {}
    local networks = {}
    local enabled = true
    --local cachedNextAd

    function self.init(_adaptor, _adFactory)
        adaptor = _adaptor
        adFactory = _adFactory
    end

    local function getNextDelay()
        return TIMEOUT[2]
    end

    -- Prevents the delay from being called more than once.
    local delayInProgress = false
    function private.delayRebuildRequests()
        if not enabled then
            return
        end
        if delayInProgress then
            return
        end
        delayInProgress = true
        private.rebuildRequestsWithDelay(getNextDelay())
    end

    function private.rebuildRequestsWithDelay(delay)
        shim.DelayCall(private.rebuildRequests, delay)
    end

    function private.cacheAds(ads)
        for _, ad in ipairs(ads) do
            private.cacheAd(ad)
        end
    end

    function private.rebuildRequests()
        if not enabled then
            return
        end
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

    function private.cacheFailed(request, response)
        request.setState(AdState.Complete)
        _error = response.getError()
        Log.d("Failed to cache ad for network (%s) type (%s) error (%s)", request.getAdNetwork(), request.getAdType(), _error)
        private.delayRebuildRequests()
    end

    function private.cacheAd(ad)
        if not enabled then
            Log.w("Ads have been disabled. Will not cache network (%s) type (%s)", ad.getAdNetwork(), ad.getAdType())
        end
        if ad.getAdType() == AdType.Banner then
            return
        end
        Log.d("Caching ad for network (%s) type (%s)", ad.getAdNetwork(), ad.getAdType())
        local request = AdRequest(ad)
        request.setState(AdState.Loading)
        local response, promise = adaptor.cache(request)
        table.insert(requests, request)

        if not response.isSuccess() then
            request.setState(AdState.Complete)
            private.delayRebuildRequests()
            Log.w("private.cacheAd: Failed to cache ad for network (%s) type (%s) error (%s)", ad.getAdNetwork(), ad.getAdType(), response.getError())
            return
        end

        Log.d("Cache request success w/ request ID (%s)", response.getId())
        promise.done(function(response)
            if response.isSuccess() then
                request.setState(AdState.Ready)
                request.setReward(response.getReward())
                Log.d("Cached ad for network (%s) type (%s)", request.getAdNetwork(), request.getAdType())
            else
                private.cacheFailed(request, response)
            end
        end)
        promise.fail(function(response)
            private.cacheFailed(request, response)
        end)
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

    function private.showAdRequest(request)
        local response, promise = adaptor.show(request)

        Log.d("Response request success w/ request ID (%s)", response.getId())
        if not response.isSuccess() then
            _error = response.getError()
            -- @fixme If an ad fails to be shown, then the ad must be invalidated and cached again.
            --request.setState(AdState.Complete)
            --private.delayRebuildRequests()
            return nil
        end

        if request.getAdType() ~= AdType.Banner then
            App.Pause()
        end

        request.setState(AdState.Presenting)
        local deferred = Promise()
        promise.done(function(response)
            request.setState(AdState.Complete)
            if response.isSuccess() then
                deferred.resolve(response.isClicked(), response.getReward())
            else
                deferred.reject(response.getError())
            end
            private.rebuildRequestsWithDelay(SHORT_TIMEOUT)
        end)
        promise.fail(function(response)
            request.setState(AdState.Complete)
            _error = response.getError()
            private.delayRebuildRequests()
            deferred.reject(_error)
        end)
        promise.always(function(response)
            App.Resume()
        end)
        return deferred
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
    -- is ready to show. This assumes that all requests are of the same ad type.
    function private.getAdRequestForAd(ad, _requests)
        for _, request in ipairs(_requests) do
            if request.getAdNetwork() == ad.getAdNetwork() and request.getState() == AdState.Ready then
                return request
            end
        end
        return nil
    end

    -- ----- Public -----

    function self.getAdFactory()
        return adFactory
    end

    function self.getRequests()
        return requests
    end

    function self.registerNetworks(networks)
        for _, network in ipairs(networks) do
            local success, err = self.registerNetwork(network)
            Log.d("Manager.registerNetworks: Network (%s) success (%s) err (%s)", network.getName(), success and "true" or "false", err and err.getMessage() or "None")
        end
    end

    function self.registerNetwork(network)
        local response = adaptor.register(AdRegisterNetworkRequest(network))
        if not response.isSuccess() then
            return false, Error(100, string.format("Failed to register network (%s)", network.getName()), response.getError())
        end
        -- Map ad ID to respective ad.
        Log.d("Manager.registerNetwork: IDs: %s", table.concat(response.getAdIds(), ","))
        local ads = network.getAds()
        for i, adId in ipairs(response.getAdIds()) do
            local ad = ads[i]
            ad.setAdId(adId)
            self.registerAd(ad)
            Log.d("Registered network (%s) type (%s) w/ ad ID (%s)", network.getName(), ad.getAdType(), adId)
        end
        table.insert(networks, network)
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

    function self.configure(config)
        local response = adaptor.configure(AdConfigureRequest(config))
        _error = response.getError()
        return response.isSuccess()
    end

    function self.getNextAdRequest(adType)
        local _requests = private.getAdRequestsForType(adType)
        if not adFactory then
            return private.getFirstAvailableAdRequest(_requests), false
        end
        -- Attempt to get the previously cached ad type until we can show it?
        --local nextAd = cachedNextAd and cachedNextAd or adFactory.nextAd(adType)
        local nextAd = adFactory.nextAd(adType)
        if nextAd then
            local request = private.getAdRequestForAd(nextAd, _requests)
            if request then
                return request, nextAd
            end
            Log.i("The next ad for network (%s) type (%s) is not ready. Returning first available ad of this type.", nextAd.getAdNetwork(), nextAd.getAdType())
        else
            Log.i("The next ad for ad type (%s) is not ready. Returning first available ad of this type.", adType)
        end
        local request = private.getFirstAvailableAdRequest(_requests)
        if request then
            local config = adFactory.getConfigForAd(request.getAdNetwork(), adType, AdImpressionType.Regular)
            return request, config
        end
        return nil, nil
    end

    function self.showAdRequest(request)
        if request then
            return private.showAdRequest(request)
        end
        _error = "Ad request is nil. This usually means the ad factory could not find an ad to serve."
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

    function self.showBannerAd(delegate)
        for _, network in ipairs(networks) do
            local ads = network.getAds()
            for _, ad in ipairs(ads) do
                if ad.getAdType() == AdType.Banner then
                    return self.showAdRequest(AdRequest(ad))
                end
            end
        end
        return nil
    end

    function self.hideBannerAd()
        local response = adaptor.hideBannerAd()
        _error = response.getError()
        return response.isSuccess()
    end

    function self.disableAds()
        enabled = false
        self.hideBannerAd()
        -- @todo Destory cache for all ads, requests, etc.
        --[[
        for _, ad in ipairs(ads) do
            bridge.destroy(ad)
        end
        --]]
    end

    function self.isEnabled()
        return enabled
    end

    function self.getError()
        return _error
    end
end

return Manager
