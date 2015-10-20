--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.AdModule")
require("ad.AdModuleProtocol")
require("ad.AdRequest")

AdMobInterstitial = Class(AdModule)
AdMobInterstitial.implements(AdModuleProtocol)

function AdMobInterstitial.new(self, zone, reward)
    function self.getConfig()
        return nil
    end

    function self.getNetworkId()
        return AdNetwork.AdMob
    end

    function self.getNetworkName()
        return "AdMob"
    end

    function self.getAdType()
        return AdType.Interstitial
    end

    function self.getZone()
        return zone
    end

    function self.getReward()
        return reward
    end

    function self.generateAdRequest()
        return AdRequest(self.getNetworkId(), self.getAdType(), self.getZone(), self.getReward())
    end
end
