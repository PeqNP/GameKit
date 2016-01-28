require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"
require "Logger"

Log.setLevel(LogLevel.Warning)

require "ad.Constants"

local shim = require("shim.Main")
local Error = require("Error")
local BridgeCall = require("bridge.BridgeCall")
local BridgeResponse = require("bridge.BridgeResponse")
local MediationAdFactory = require("mediation.AdFactory")
local MediationAdConfig = require("mediation.AdConfig")
local Ad = require("ad.Ad")
local AdManager = require("ad.Manager")
local AdRegisterNetworkResponse = require("ad.response.AdRegisterNetworkResponse")
local AdRequest = require("ad.request.AdRequest")
local AdConfigureRequest = require("ad.request.AdConfigureRequest")
local AdRegisterNetworkRequest = require("ad.request.AdRegisterNetworkRequest")
local AdCompleteResponse = require("ad.response.AdCompleteResponse")
local AdCacheResponse = require("ad.response.AdCacheResponse")
local AdMobNetwork = require("ad.network.AdMobNetwork")
local AdColonyNetwork = require("ad.network.AdColonyNetwork")

local match = require("specs.matchers")
matchers_assert(assert)

Singleton("Music")

function reload(pckg)
    package.loaded[pckg] = nil
    return require(pckg)
end

function Ad.init4(adNetwork, adType, zoneId, reward, adId)
    local ad = Ad(adType, zoneId, reward)
    ad.setAdNetwork(adNetwork)
    return ad
end

describe("AdManager", function()
    local subject
    local config
    local bridge
    local adFactory

    before_each(function()
        bridge = require("bridge.modules.ad")
        adFactory = mock(MediationAdFactory({}), true)

        subject = AdManager(bridge, adFactory)
    end)

    it("should set the ad factory", function()
        assert.equal(adFactory, subject.getAdFactory())
    end)

    it("should not have an ad available", function()
        assert.falsy(subject.isAdAvailable(AdType.Interstitial))
    end)

    it("should not have an error", function()
        assert.falsy(subject.getError())
    end)

    context("when configuring the service", function()
        local request
        local ret

        context("when successful", function()
            before_each(function()
                request = {}
                stub(bridge, "configure", BridgeResponse(true))
                ret = subject.configure(request)
            end)

            it("should have sent the message to configure", function()
                assert.stub(bridge.configure).was.called_with(match.is_kind_of(AdConfigureRequest))
            end)

            it("should have returned true", function()
                assert.truthy(ret)
            end)
        end)

        context("when failure", function()
            before_each(function()
                request = {}
                stub(bridge, "configure", BridgeResponse(false, nil, "An error"))
                ret = subject.configure(request)
            end)

            it("should have sent the message to configure", function()
                assert.stub(bridge.configure).was.called_with(match.is_kind_of(AdConfigureRequest))
            end)

            it("should have returned true", function()
                assert.falsy(ret)
            end)
            
            it("should have set the error", function()
                assert.equal("An error", subject.getError())
            end)
        end)
    end)

    context("when registering networks", function()
        local adMob
        local bannerAd
        local interstitialAd
        local success, _error

        context("when the network is successfully registered", function()
            before_each(function()
                networks = reload("specs.Mediation-test")
                adMob = networks[2]
                bannerAd = adMob.getAds()[1]
                interstitialAd = adMob.getAds()[2]

                stub(bridge, "register", AdRegisterNetworkResponse(true, "100,200"))
                stub(subject, "registerAd")

                success, _error = subject.registerNetwork(adMob)
            end)

            it("should have returned a response", function()
                assert.truthy(success)
                assert.falsy(_error)
            end)

            it("should have registered all of the networks", function()
                assert.stub(bridge.register).was.called_with(match.is_kind_of(AdRegisterNetworkRequest))
            end)

            it("should have associated ad IDs to respective ads", function()
                assert.equals(100, bannerAd.getAdId())
                assert.equals(200, interstitialAd.getAdId())
            end)

            it("should have registered all ads", function()
                assert.stub(subject.registerAd).was.called_with(bannerAd)
                assert.stub(subject.registerAd).was.called_with(interstitialAd)
            end)

            context("when hiding the banner ad", function()
                context("when it succeeds", function()
                    before_each(function()
                        stub(bridge, "hideBannerAd", BridgeResponse(true))
                        success = subject.hideBannerAd()
                    end)

                    it("should return success w/ no error", function()
                        assert.truthy(success)
                        assert.falsy(subject.getError())
                    end)

                    it("should have made call to hide the ad", function()
                        assert.stub(bridge.hideBannerAd).was.called()
                    end)
                end)

                context("when it fails", function()
                    before_each(function()
                        stub(bridge, "hideBannerAd", BridgeResponse(false, nil, "Error"))
                        success = subject.hideBannerAd()
                    end)

                    it("should fail w/ error", function()
                        assert.falsy(success)
                        assert.equal("Error", subject.getError())
                    end)

                    it("should have made call to hide the ad", function()
                        assert.stub(bridge.hideBannerAd).was.called()
                    end)
                end)
            end)
        end)

        context("when the networks fails to be registered", function()
            before_each(function()
                networks = reload("specs.Mediation-test")
                adMob = networks[2]
                bannerAd = adMob.getAds()[1]
                interstitialAd = adMob.getAds()[2]

                stub(bridge, "register", AdRegisterNetworkResponse(false, nil, "Info"))
                stub(subject, "registerAd")

                success, _error = subject.registerNetwork(adMob)
            end)

            it("should return correct response", function()
                assert.falsy(success)
                assert.equals(Error, _error.getClass())
                assert.equals(100, _error.getCode())
                assert.equals("Failed to register network (AdMob)", _error.getMessage())
                assert.equals("Info", _error.getInfo())
            end)

            it("should NOT have associated ad IDs to respective ads", function()
                assert.falsy(bannerAd.getAdId())
                assert.falsy(interstitialAd.getAdId())
            end)

            it("should have registered all ads", function()
                assert.stub(subject.registerAd).was_not.called_with(bannerAd)
                assert.stub(subject.registerAd).was_not.called_with(interstitialAd)
            end)
        end)
    end)

    context("registering more than one network at a time", function()
        local adColony
        local adMob

        before_each(function()
            networks = reload("specs.Mediation-test")
            adColony = networks[1]
            adMob = networks[2]

            stub(subject, "registerNetwork")

            subject.registerNetworks(networks)
        end)

        it("should have registered all networks", function()
            assert.stub(subject.registerNetwork).was.called_with(adColony)
            assert.stub(subject.registerNetwork).was.called_with(adMob)
        end)
    end)

    -- @todo these tests exists only to hit the code that emits the log message.
    -- In the future this could return a list of errors with the networks.
    context("when registering more than one network and there is an error", function()
        local adColony
        local adMob

        before_each(function()
            networks = reload("specs.Mediation-test")
            adColony = networks[1]
            adMob = networks[2]

            stub(subject, "registerNetwork", false, Error(100, "admanager_spec failure"))

            subject.registerNetworks(networks)
        end)

        it("should have registered all networks", function()
            assert.stub(subject.registerNetwork).was.called_with(adColony)
            assert.stub(subject.registerNetwork).was.called_with(adMob)
        end)
    end)

    describe("show nil ad request", function()
        before_each(function()
            subject.showAdRequest(nil)
        end)

        it("should have returned correct error", function()
            assert.equal("Ad request is nil. This usually means the ad factory could not find an ad to serve.", subject.getError())
        end)
    end)

    describe("adding ad modules", function()
        local requests
        local adb
        local adi
        local requesti
        local responsei
        local promisei
        local adv
        local requestv
        local responsev
        local promisev
        local leadbolt_ad
        local leadbolt_response
        local leadbolt_promise 

        before_each(function()
            adb = Ad.init4(AdNetwork.AdMob, AdType.Banner, "banner-zone")
            adi = Ad.init4(AdNetwork.AdMob, AdType.Interstitial, "interstitial-zone")
            adv = Ad.init4(AdNetwork.AdColony, AdType.Video, "interstitial-zone")
            leadbolt_ad = Ad.init4(AdNetwork.Leadbolt, AdType.Interstitial, nil)

            responsei = BridgeResponse(true, 100)
            responsev = BridgeResponse(true, 110)
            leadbolt_response = BridgeResponse(true, 120)

            function bridge.cache(request)
                if request.getAdNetwork() == AdNetwork.AdMob then
                    promisei = BridgeCall()
                    return responsei, promisei
                elseif request.getAdNetwork() == AdNetwork.AdColony then
                    promisev = BridgeCall()
                    return responsev, promisev
                elseif request.getAdNetwork() == AdNetwork.Leadbolt then
                    leadbolt_promise = BridgeCall()
                    return leadbolt_response, leadbolt_promise
                else
                    assert.truthy(false)
                end
            end

            subject.registerAd(adi)
            subject.registerAd(adv)
            subject.registerAd(adb)

            requests = subject.getRequests()
        end)

        it("should have added the network module to list of registered modules", function()
            local modules = subject.getRegisteredAds()
            assert.equal(3, #modules)
            assert.equal(adi, modules[1])
            assert.equal(adv, modules[2])
            assert.equal(adb, modules[3])
        end)

        it("should have created two requests for none banner ads", function()
            assert.equal(2, #requests)
        end)

        it("should have two requests waiting to be cached", function()
            requesti = requests[1]
            requestv = requests[2]
            assert.equal(AdState.Loading, requesti.getState())
            assert.equal(AdState.Loading, requestv.getState())
            assert.truthy(promisei)
            assert.truthy(promisev)
        end)

        it("should not have an available network module", function()
            assert.falsy(subject.isAdAvailable(AdType.Interstitial))
            assert.falsy(subject.isAdAvailable(AdType.Video))
        end)

        it("should NOT show the ad", function()
            assert.falsy(subject.showAd(AdType.Interstitial))
            assert.falsy(subject.showAd(AdType.Video))
        end)

        describe("when the interstitial ad is cached", function()
            local requesti
            local requestv

            before_each(function()
                requesti = requests[1]
                requestv = requests[2]
                promisei.resolve(AdCacheResponse(true, 100))
            end)

            it("should have an available interstitial", function()
                assert.truthy(subject.isAdAvailable(AdType.Interstitial))
            end)

            it("should NOT have an available video", function()
                assert.falsy(subject.isAdAvailable(AdType.Video))
            end)    

            context("when there is no config", function()
                before_each(function()
                    stub(adFactory, "nextAd", nil)
                end)

                describe("show the ad", function()
                    before_each(function()
                        local promise = BridgeCall()
                        stub(bridge, "show", responsei, promise)

                        assert.falsy(subject.showAd(AdType.Video))
                        assert.truthy(subject.showAd(AdType.Interstitial))
                    end)

                    it("should show an AdMob ad", function()
                        assert.equal(AdNetwork.AdMob, requesti.getAdNetwork())
                    end)

                    it("should show the interstitial ad", function()
                        assert.stub(bridge.show).was.called_with(requesti)
                    end)

                    it("should NOT have shown the video ad", function()
                        assert.stub(bridge.show).was_not.called_with(requestv)
                    end)
                end)
            end)

            context("when AdMob is configured to be shown", function()
                local config

                before_each(function()
                    config = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
                    stub(adFactory, "nextAd", config)
                end)

                context("when showing the ad is successful", function()
                    before_each(function()
                        local promise = BridgeCall()
                        stub(bridge, "show", responsei, promise)
                        assert.truthy(subject.showAd(AdType.Interstitial))
                    end)

                    it("should have shown an AdMob ad", function()
                        assert.stub(bridge.show).was.called_with(requesti)
                    end)
                end)

                context("when showing the ad fails", function()
                    before_each(function()
                        local promise = BridgeCall()
                        stub(bridge, "show", BridgeResponse(false, 50), promise)
                        assert.falsy(subject.showAd(AdType.Interstitial))
                    end)

                    it("should have shown an AdMob ad", function()
                        assert.stub(bridge.show).was.called_with(requesti)
                    end)
                end)
            end)

            context("when getting the AdMob next request", function()
                local config

                before_each(function()
                    local promise = BridgeCall()
                    stub(bridge, "show", responsei, promise)

                    config = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
                    stub(adFactory, "nextAd", config)
                end)

                it("should return the ad config", function()
                    local request, ad = subject.getNextAdRequest(AdType.Interstitial)
                    assert.equals(AdRequest, request.getClass())
                    assert.equals(config, ad)
                end)
            end)

            context("when showing an ad type that is NOT registered", function()
                local config

                before_each(function()
                    local promise = BridgeCall()
                    stub(bridge, "show", responsei, promise)

                    config = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
                    stub(adFactory, "nextAd", config)
                    assert.truthy(subject.showAd(AdType.Interstitial))
                end)

                it("should show the next available ad type instead; AdMob", function()
                    assert.stub(bridge.show).was.called_with(requesti)
                end)
            end)

            context("when showing an ad type that is registed", function()
                local config

                before_each(function()
                    config = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
                    stub(adFactory, "nextAd", config)

                    local promise = BridgeCall()
                    stub(bridge, "show", leadbolt_response, promise)

                    subject.registerAd(leadbolt_ad)
                end)

                context("when the ad has not yet been cached", function()
                    before_each(function()
                        assert.truthy(subject.showAd(AdType.Interstitial))
                    end)

                    it("should show the next available ad type instead; AdMob", function()
                        assert.stub(bridge.show).was.called_with(requesti)
                    end)
                end)

                context("when the ad fails to be cached", function()
                    before_each(function()
                        leadbolt_promise.resolve(BridgeResponse(false, 120, "Leadbolt error"))
                        assert.truthy(subject.showAd(AdType.Interstitial))
                    end)

                    it("should show the next available ad type instead; AdMob", function()
                        assert.stub(bridge.show).was.called_with(requesti)
                    end)
                end)
            end)

            context("when getting the next AdRequest", function()
                local config
                local adConfig

                before_each(function()
                    local promise = BridgeCall()
                    stub(bridge, "show", responsei, promise)

                    config = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
                    stub(adFactory, "nextAd", config)

                    adConfig = {}
                    stub(adFactory, "getConfigForAd", adConfig)
                end)

                it("should return an AdMob request and config", function()
                    local request, config = subject.getNextAdRequest(AdType.Interstitial)
                    assert.equal(AdNetwork.AdMob, request.getAdNetwork())
                    assert.equal(adConfig, config)
                end)
            end)
        end)

        context("when the ad fails to be cached", function()
            local delayfn
            local delayval

            before_each(function()
                function shim.DelayCall(fn, delay)
                    delayfn = fn
                    delayval = delay
                end

                spy.on(shim, "DelayCall")

                requesti = requests[1]
                promisei.reject(BridgeResponse(false, 100, "Cache failure"))
            end)

            it("should have completed request", function()
                assert.equal(AdState.Complete, requesti.getState())
            end)

            it("should have set the error", function()
                assert.equal("Cache failure", subject.getError())
            end)

            it("should not be available", function()
                assert.falsy(subject.isAdAvailable(AdType.Interstitial))
            end)

            it("should have scheduled the request to be performed at a later time", function()
                assert.equals(30, delayval)
            end)

            describe("caching the module that failed", function()
                before_each(function()
                    delayfn()

                    requests = subject.getRequests()
                end)

                it("should have rescheduled the module", function()
                    assert.equal(2, #requests)
                end)

                it("should have an interstitial pending", function()
                    local request = requests[2]
                    assert.equal(AdNetwork.AdMob, request.getAdNetwork())
                    assert.equal(AdType.Interstitial, request.getAdType())
                    assert.equal(AdState.Loading, request.getState())
                end)
            end)
        end)

        context("when the video ad is ready w/ a reward", function()
            before_each(function()
                requesti = requests[1]
                requestv = requests[2]
                promisev.resolve(AdCacheResponse(true, 110, 44))
            end)

            it("should have set the reward on the request", function()
                assert.equal(44, requestv.getReward())
            end)
        end)

        context("when the video ad is ready", function()
            before_each(function()
                requesti = requests[1]
                requestv = requests[2]
                promisev.resolve(AdCacheResponse(true, 110))
            end)

            it("should NOT have an available interstitial", function()
                assert.falsy(subject.isAdAvailable(AdType.Interstitial))
            end)

            it("should have an available video", function()
                assert.truthy(subject.isAdAvailable(AdType.Video))
            end)

            it("should not have set the reward, as none was given", function()
                assert.falsy(requestv.getReward())
            end)

            context("when there is no config for the video", function()
                describe("show the ad", function()
                    local promise
                    local ad_promise
                    local ad_clicked
                    local ad_reward
                    local ad_error

                    before_each(function()
                        ad_clicked = nil
                        ad_reward = nil
                        ad_error = nil

                        promise = BridgeCall()
                        stub(adFactor, nextAd, nil)
                        stub(bridge, "show", responsei, promise)
                        stub(shim, "DelayCall")

                        show_promise = subject.showAd(AdType.Video)
                        assert.truthy(show_promise) -- sanity
                        show_promise.done(function(clicked, reward)
                            ad_clicked = clicked
                            ad_reward = reward
                        end)
                        show_promise.fail(function(_error)
                            ad_error = _error
                        end)
                    end)

                    it("should not show interstitial, as it is not cached (sanity)", function()
                        assert.falsy(subject.showAd(AdType.Interstitial))
                    end)

                    it("should show the video ad", function()
                        assert.stub(bridge.show).was.called_with(requestv)
                    end)

                    it("should be presenting the request", function()
                        assert.equal(AdState.Presenting, requestv.getState())
                    end)

                    describe("when the ad completes successfully", function()
                        before_each(function()
                            stub(bridge, "cache", BridgeResponse(true, 100), BridgeCall())
                            promise.resolve(AdCompleteResponse(true, 1, 10, true))
                        end)

                        it("should have set the click and reward", function()
                            assert.truthy(ad_clicked)
                            assert.equal(10, ad_reward)
                        end)

                        it("should have updated the state of the ad request", function()
                            assert.equal(AdState.Complete, requestv.getState())
                        end)

                        it("should cache ad immediately", function()
                            assert.stub(bridge.cache).was.called()
                        end)
                    end)

                    describe("when the request fails", function()
                        before_each(function()
                            promise.reject(AdCompleteResponse(false, 1, 0, false, "Failure"))
                        end)

                        it("should have updated the state of the ad request", function()
                            assert.equal(AdState.Complete, requestv.getState())
                        end)

                        it("should have an error", function()
                            assert.equal("Failure", subject.getError())
                            assert.equal("Failure", ad_error)
                        end)

                        it("should attempt to cache module", function()
                            assert.stub(shim.DelayCall).was.called()
                        end)
                    end)
                end)
            end)
        end)
    end)
end)

describe("AdManager when no ad factory", function()
    local subject
    local adFactory
    local ad
    local request
    local promisec
    local promises
    local responsec -- 'c' for 'cache'
    local responses -- 's' for 'show'

    before_each(function()
        promisec = BridgeCall()
        promises = BridgeCall()

        bridge = require("bridge.modules.ad")
        function bridge.cache(request)
            return responsec, promisec
        end
        function bridge.show(request)
            return responses, promises
        end
        bridge = mock(bridge)

        stub(shim, "DelayCall")

        subject = AdManager(bridge)

        ad = Ad.init4(AdNetwork.AdMob, AdType.Interstitial, "adid", 5)
    end)

    context("when the ad is cached successfully", function()
        local request

        before_each(function()
            -- @note These vars are used in first before_each when bridge.* methods are called.
            responsec = BridgeResponse(true, 50)
            responses = BridgeResponse(true, 60)

            subject.registerAd(ad)

            request = subject.getRequests()[1]
            promisec.resolve(AdCacheResponse(true, 50, 66))
        end)

        it("should have created a request", function()
            local requests = subject.getRequests()
            assert.equals(1, #requests) -- sanity
            local request = requests[1]
            assert.truthy(request) -- should have created a request
        end)

        it("should have set the reward", function()
            assert.equal(66, request.getReward())
        end)

        it("should have cached the ad", function()
            assert.spy(bridge.cache).was.called()
        end)

        it("should have displayed an AdMob interstitial ad", function()
            assert.truthy(subject.showAd(AdType.Interstitial))
            assert.spy(bridge.show).was.called_with(request)
        end)

        it("should return request and no ad", function()
            local request, ad = subject.getNextAdRequest(AdType.Interstitial)
            assert.equals(AdRequest, request.getClass())
            assert.falsy(ad)
        end)

        it("should not return request or ad if the add type is not registered", function()
            local request, ad = subject.getNextAdRequest(AdType.Video)
            assert.falsy(request)
            assert.falsy(ad)
        end)
    end)

    context("when the ad fails to be cached", function()
        local request

        before_each(function()
            responsec = AdCacheResponse(false, 50, nil, "cache error")
            responses = BridgeResponse(false, 60, "show error")

            subject.registerAd(ad)
        end)

        it("should try to rebuild the requests after 30 seconds", function()
            assert.stub(shim.DelayCall).was.called_with(match._, 30)
        end)

        it("should not have added request to tracked requests", function()
            local requests = subject.getRequests()
            assert.equals(0, #requests)
        end)

        it("should NOT allow AdMob interstitial ad to be displayed", function()
            assert.falsy(subject.showAd(AdType.Interstitial))
        end)
    end)
end)
