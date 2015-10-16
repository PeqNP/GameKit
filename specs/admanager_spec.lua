require "lang.Signal"

require "ad.Constants"
require "ad.AdManager"

describe("AdManager", function()
    local subject
    local config
    local delegate

    before_each(function()
        delegate = {}
        config = {}

        subject = AdManager(config)
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

    describe("adding network modules", function()
        local module
        local state

        before_each(function()
            state = AdState.Initial
            module = {}
            function module.getState()
                return state
            end
            stub(module, "getAdType").and_return(AdType.Interstitial)

            subject.registerNetworkModule(module)
        end)

        it("should have added the network module to list of registered modules", function()
            local modules = subject.getRegisteredNetworkModules()
            assert.equal(1, #modules)
            assert.equal(module, modules[1])
        end)

        it("should not have an available network module", function()
            assert.falsy(subject.isAdAvailable(AdType.Interstitial))
        end)

        describe("when the ad is ready", function()
            before_each(function()
                state = AdState.Ready
            end)

            it("should have an available network", function()
                assert.truthy(subject.isAdAvailable(AdType.Interstitial))
            end)
        end)
    end)
end)
