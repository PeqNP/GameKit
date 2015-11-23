require "lang.Signal"

require "ad.Constants"
require "ad.Ad"
require "ad.AdRequest"
require "ad.networks.AdMobNetwork"

describe("AdRequest", function()
    local subject
    local ad

    before_each(function()
        ad = Ad(AdType.Interstitial, "zone", 25)
        ad.setAdNetwork(AdNetwork.AdMob)
        ad.setToken("token")
        subject = AdRequest(ad)
    end)

    it("should return the ad", function()
        assert.equals(ad, subject.getAd())
    end)

    it("should be in the initial state by default", function()
        assert.equal(AdState.Initial, subject.getState())
    end)

    it("should return the network", function()
        assert.equal(AdNetwork.AdMob, subject.getAdNetwork())
    end)

    it("should return correct ad type", function()
        assert.equal(AdType.Interstitial, subject.getAdType())
    end)

    it("should return the correct zone", function()
        assert.truthy(subject.getZoneId()) -- sanity. Make sure it is a value and not nil.
        assert.equal("zone", subject.getZoneId())
    end)

    it("should return the correct reward", function()
        assert.truthy(subject.getReward()) -- sanity. Make sure it is a value and not nil.
        assert.equal(25, subject.getReward())
    end)

    it("should return the correct token", function()
        assert.equals("token", subject.getToken())
    end)

    -- BridgeRequestProtocol

    it("should return the correct ID", function()
        assert.equals("token", subject.getId())
    end)

    it("should return dictionary with config", function()
        -- @todo
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

