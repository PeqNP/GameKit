--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.AdModule")
require("ad.AdModuleProtocol")
require("ad.AdRequest")

AdColonyVideo = Class(AdModule)
AdColonyVideo.implements(AdModuleProtocol)

function AdColonyVideo.new(self, zone, reward)
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
