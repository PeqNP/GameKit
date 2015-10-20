require "lang.Signal"

require "ad.Constants"
require "ad.AdManager"
require "ad.AdModule"
require "ndk.AdAdaptor"

describe("AdManager", function()
    local subject
    local config
    local delegate
    local adaptor

    before_each(function()
        delegate = {}
        config = {}
        adaptor = mock(AdAdaptor(), true)

        subject = AdManager(adaptor, config)
        subject.setDelegate(delegate)
    end)

    it("should set the config", function()
        assert.equal(config, subject.getConfig())
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
        local modulei
        local statei

        local modulev
        local statev

        before_each(function()
            statei = AdState.Initial
            statev = AdState.Initial
            modulei = AdModule()
            modulev = AdModule()
            function modulei.getState()
                return statei
            end
            function modulev.getState()
                return statev
            end
            stub(modulei, "getAdType").and_return(AdType.Interstitial)
            stub(modulev, "getAdType").and_return(AdType.Video)

            subject.registerNetworkModule(modulei)
            subject.registerNetworkModule(modulev)
        end)

        it("should have added the network module to list of registered modules", function()
            local modules = subject.getRegisteredNetworkModules()
            assert.equal(2, #modules)
            assert.equal(modulei, modules[1])
            assert.equal(modulev, modules[2])
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
            before_each(function()
                statei = AdState.Ready
            end)

            it("should have an available interstitial", function()
                assert.truthy(subject.isAdAvailable(AdType.Interstitial))
            end)

            it("should show the interstitial ad", function()
                assert.truthy(subject.showAd(AdType.Interstitial))
            end)

            it("should NOT have an available video", function()
                assert.falsy(subject.isAdAvailable(AdType.Video))
            end)    
        end)

        describe("when the video ad is ready", function()
            before_each(function()
                statev = AdState.Ready
            end)

            it("should NOT have an available interstitial", function()
                assert.falsy(subject.isAdAvailable(AdType.Interstitial))
            end)

            it("should have an available video", function()
                assert.truthy(subject.isAdAvailable(AdType.Video))
            end)    

            it("should show the video ad", function()
                assert.truthy(subject.showAd(AdType.Video))
            end)
        end)
    end)
end)
