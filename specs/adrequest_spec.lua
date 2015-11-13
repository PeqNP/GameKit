require "lang.Signal"

require "ad.Constants"
require "ad.AdRequest"
require "ad.modules.AdMobInterstitial"

describe("AdRequest", function()
    local subject
    local adModule

    before_each(function()
        adModule = AdMobInterstitial("zone", 25)
        subject = AdRequest(adModule)
    end)

    -- Start: These MUST be the first two tests! --
    it("should have created a new ID", function()
        assert.equal(1, subject.getId())
    end)

    it("should have created a new ID for second subject", function()
        assert.equal(2, subject.getId())
    end)
    -- End --

    it("should be in the initial state by default", function()
        assert.equal(AdState.Initial, subject.getState())
    end)

    it("should return correct adModule", function()
        assert.equal(adModule, subject.getAdModule())
    end)

    it("should return correct ad network", function()
        assert.equal(AdNetwork.AdMob, subject.getAdNetwork())
    end)

    it("should return correct ad type", function()
        assert.equal(AdType.Interstitial, subject.getAdType())
    end)

    it("should return the correct zone", function()
        assert.truthy(subject.getZone()) -- sanity. Make sure it is a value and not nil.
        assert.equal("zone", subject.getZone())
    end)

    it("should return the correct reward", function()
        assert.truthy(subject.getReward()) -- sanity. Make sure it is a value and not nil.
        assert.equal(25, subject.getReward())
    end)

    describe("state", function()
        before_each(function()
            subject.setState(AdState.Ready)
        end)

        it("should have set the state", function()
            assert.equal(AdState.Ready, subject.getState())
        end)
    end)
end)

