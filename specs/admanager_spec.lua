require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

require "Common"
require "ad.Constants"
require "ad.Ad"
require "ad.AdManager"
require "ad.AdResponse"
require "ad.networks.AdMobNetwork"
require "ad.networks.AdColonyNetwork"
require "mediation.MediationAdFactory"
require "mediation.MediationAdConfig"

function Ad.init4(adNetwork, adType, zoneId, reward, token)
    local ad = Ad(adType, zoneId, reward)
    ad.setAdNetwork(adNetwork)
    return ad
end

describe("AdManager", function()
    local subject
    local config
    local delegate
    local bridge
    local adFactory

    before_each(function()
        delegate = {}
        bridge = require("bridge.modules.ad")
        adFactory = mock(MediationAdFactory({}), true)

        subject = AdManager(bridge, adFactory)
        subject.setDelegate(delegate)
    end)

    it("should set the ad factory", function()
        assert.equal(adFactory, subject.getAdFactory())
    end)

    it("should have set the delegate", function()
        assert.equal(delegate, subject.getDelegate())
    end)

    it("should not have an ad available", function()
        assert.falsy(subject.isAdAvailable(AdType.Interstitial))
    end)

    it("should not have an error", function()
        assert.falsy(subject.getError())
    end)

    describe("adding network modules", function()
        local requests
        local adi
        local requesti
        local promisei
        local adv
        local requestv
        local promisev

        before_each(function()
            adi = Ad.init4(AdNetwork.AdMob, AdType.Interstitial, "interstitial-zone")
            adv = Ad.init4(AdNetwork.AdColony, AdType.Video, "interstitial-zone")

            function bridge.cache(request)
                if request.getAdNetwork() == AdNetwork.AdMob then
                    promisei = Promise()
                    return promisei
                elseif request.getAdNetwork() == AdNetwork.AdColony then
                    promisev = Promise()
                    return promisev
                else
                    assert.truthy(false)
                end
            end

            subject.registerAd(adi)
            subject.registerAd(adv)

            requests = subject.getRequests()

            -- @todo Resolve promise which associates token to ad.
        end)

        it("should have made call to bridge to register network", function()
        end)

        it("should have added the network module to list of registered modules", function()
            local modules = subject.getRegisteredAds()
            assert.equal(2, #modules)
            assert.equal(adi, modules[1])
            assert.equal(adv, modules[2])
        end)

        it("should have created two requests", function()
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

        describe("when the interstitial ad is ready", function()
            local requesti
            local requestv

            before_each(function()
                requesti = requests[1]
                requestv = requests[2]
                promisei.resolve(AdResponse(requesti.getToken(), AdState.Ready))
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
                        local promise = Promise()
                        stub(bridge, "show", promise)

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
                    local promise = Promise()
                    stub(bridge, "show", promise)

                    config = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
                    stub(adFactory, "nextAd", config)
                    assert.truthy(subject.showAd(AdType.Interstitial))
                end)

                it("should have shown an AdMob ad", function()
                    assert.stub(bridge.show).was.called_with(requesti)
                end)
            end)

            context("when Leadbolt is configured to be shown but module is not registered", function()
                local config

                before_each(function()
                    local promise = Promise()
                    stub(bridge, "show", promise)

                    config = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
                    stub(adFactory, "nextAd", config)
                    assert.truthy(subject.showAd(AdType.Interstitial))
                end)

                it("should show the next available ad type, AdMob", function()
                    assert.stub(bridge.show).was.called_with(requesti)
                end)
            end)
        end)

        context("when the ad fails to be cached", function()
            local delayfn

            before_each(function()
                function cu.delayCall(fn, delay)
                    delayfn = fn
                end

                spy.on(cu, "delayCall")

                requesti = requests[1]
                promisei.reject(AdResponse(requesti.getToken(), AdState.Complete, 0, false, "Cache failure"))
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
                -- @fixme Called with what value?
                assert.stub(cu.delayCall).was.called()
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

        context("when the video ad is ready", function()
            before_each(function()
                requesti = requests[1]
                requestv = requests[2]
                promisev.resolve(AdResponse(requestv.getToken(), AdState.Ready))
            end)

            it("should NOT have an available interstitial", function()
                assert.falsy(subject.isAdAvailable(AdType.Interstitial))
            end)

            it("should have an available video", function()
                assert.truthy(subject.isAdAvailable(AdType.Video))
            end)    

            context("when there is no config for the video", function()
                describe("show the ad", function()
                    local promise

                    before_each(function()
                        promise = Promise()
                        stub(adFactor, nextAd, nil)
                        stub(bridge, "show", promise)
                        stub(cu, "delayCall")

                        assert.falsy(subject.showAd(AdType.Interstitial))
                        assert.truthy(subject.showAd(AdType.Video))
                    end)

                    it("should show the video ad", function()
                        assert.stub(bridge.show).was.called_with(requestv)
                    end)

                    it("should be presenting the request", function()
                        assert.equal(AdState.Presenting, requestv.getState())
                    end)

                    describe("when the ad is closed", function()
                        before_each(function()
                            promise.resolve(AdResponse(requestv.getToken(), AdState.Complete))
                        end)

                        it("should have updated the state of the ad request", function()
                            assert.equal(AdState.Complete, requestv.getState())
                        end)

                        it("should cache module", function()
                            assert.stub(cu.delayCall).was.called()
                        end)
                    end)

                    describe("when the ad is clicked", function()
                        before_each(function()
                            promise.resolve(AdResponse(requestv.getToken(), AdState.Clicked))
                        end)

                        it("should have updated the state of the ad request", function()
                            assert.equal(AdState.Clicked, requestv.getState())
                        end)

                        it("should cache module", function()
                            assert.stub(cu.delayCall).was.called()
                        end)
                    end)

                    describe("when the request fails", function()
                        before_each(function()
                            promise.reject(AdResponse(requestv.getToken(), AdState.Complete, 0, false, "Failure"))
                        end)

                        it("should have updated the state of the ad request", function()
                            assert.equal(AdState.Complete, requestv.getState())
                        end)

                        it("should have an error", function()
                            assert.equal("Failure", subject.getError())
                        end)

                        it("should attempt to cache module", function()
                            assert.stub(cu.delayCall).was.called()
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

    before_each(function()
        promisec = Promise()
        promises = Promise()

        bridge = require("bridge.modules.ad")
        stub(bridge, "cache", promisec)
        stub(bridge, "show", promises)

        subject = AdManager(bridge)

        ad = Ad.init4(AdNetwork.AdMob, AdType.Interstitial, "token", 5)
        subject.registerAd(ad)
    end)

    it("should have created a request", function()
        local requests = subject.getRequests()
        assert.equals(1, #requests) -- sanity
        local request = requests[1]
        assert.truthy(request) -- should have created a request
    end)

    it("should have cached the ad", function()
        assert.stub(bridge.cache).was.called()
    end)

    context("when the ad is cached successfully", function()
        local request

        before_each(function()
            request = subject.getRequests()[1]
            promisec.resolve(AdResponse(request.getToken(), AdState.Ready))
        end)

        it("should have displayed an AdMob interstitial ad", function()
            assert.truthy(subject.showAd(AdType.Interstitial))
            assert.stub(bridge.show).was.called_with(request)
        end)
    end)
end)
