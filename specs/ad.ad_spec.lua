require "lang.Signal"

require "ad.Constants"
local Ad = require("ad.Ad")

describe("Ad", function()
    local subject

    before_each(function()
        subject = Ad(AdType.Interstitial, "MyZoneId", AdLocation.Bottom)
    end)

    it("should have set properties", function()
        assert.equals(AdType.Interstitial, subject.getAdType())
        assert.equals("MyZoneId", subject.getZoneId())
        assert.equals(AdLocation.Bottom, subject.getLocation())
    end)

    describe("setting the network", function()
        before_each(function()
            subject.setAdNetwork(AdNetwork.AdColony)
        end)

        it("should have set the ad network", function()
            assert.equals(AdNetwork.AdColony, subject.getAdNetwork())
        end)
    end)

    describe("setting the ad ID", function()
        before_each(function()
            subject.setAdId("adid")
        end)

        it("should have set the ad ID", function()
            assert.equals("adid", subject.getAdId())
        end)
    end)
end)
