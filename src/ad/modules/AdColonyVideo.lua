--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.AdModule")
require("ad.AdRequest")

AdColonyVideo = Class(AdModule)

function AdColonyVideo.new(self)
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
        return AdNetwork.AdColony
    end

    function self.getAdNetworkName()
        return "AdColony"
    end

    function self.getAdType()
        return AdType.Video
    end

    function self.getZone()
        return zone
    end

    function self.getReward()
        return reward
    end
end
