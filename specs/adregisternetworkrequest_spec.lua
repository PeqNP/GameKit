require "lang.Signal"

require "ad.Constants"
require "ad.Ad"
require "ad.AdNetworkModule"
require "ad.request.AdRegisterNetworkRequest"

TestAdNetwork = Class(AdNetworkModule)
function TestAdNetwork.new(self)
    function self.getAdNetwork()
        return AdNetwork.Unknown
    end

    function self.getConfig()
        return {appid=1}
    end

    function self.getName()
        return "Unknown"
    end
end

describe("AdRegisterNetworkRequest", function()
    local subject

    before_each(function()
        subject = AdRegisterNetworkRequest(TestAdNetwork({Ad(AdType.Interstitial, "123"), Ad(AdType.Video, "456")}))
    end)

    it("should return correct dictionary", function()
        local dict = subject.toDict()
        assert.truthy(table.equals(dict, {network="Unknown", appid=1, ads={{type=AdType.Interstitial, zoneid="123"}, {type=AdType.Video, zoneid="456"}}}))
    end)
end)
