--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.AdModule")
require("ad.AdRequest")

AdMobInterstitial = Class(AdModule)

function AdMobInterstitial.new(self)
    local zone
    local reward

    function self.init(_zone, _reward)
        zone = _zone
        reward = _reward
    end

    function self.getConfig()
        return nil
    end

    function self.getAdNetwork()
        return AdNetwork.AdMob
    end

    function self.getAdNetworkName()
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
end
