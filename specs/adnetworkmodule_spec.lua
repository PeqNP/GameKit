require "lang.Signal"

require "ad.Ad"
require "ad.AdNetworkModule"
require "ad.Constants"

TestNetwork = Class(AdNetworkModule)
function TestNetwork.new(self)
    function self.getName()
        return "TestName"
    end

    function self.getAdNetwork()
        return 100
    end

    function self.getConfig()
        return {}
    end
end

describe("AdNetworkModule", function()
    local subject
    local ad
    local ads

    before_each(function()
        ad = Ad(AdType.Interstitial, "zone")
        ads = {ad}
        subject = TestNetwork(ads)
    end)

    it("should have set the network on the AD", function()
        assert.equals(100, ad.getAdNetwork())
    end)

    it("should return the correct ads", function()
        assert.equals(ads, subject.getAds())
    end)
end)
