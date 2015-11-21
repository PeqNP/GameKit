--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.AdNetworkModule"

AdMobNetwork = Class(AdNetworkModule)

function AdMobNetwork.new(self, init)
    function self.getName()
        return "AdMob"
    end

    function getConfig()
        return {"network" = self.getName(), "ads": self.getAdConfig()}
    end
end
