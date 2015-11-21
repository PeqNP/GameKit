--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.AdNetworkModule"

iAdNetwork = Class(AdNetworkModule)

function iAdNetwork.new(self, init)
    function self.getName()
        return "iAd"
    end

    function getConfig()
        return {"network" = self.getName(), "appid": appid, "ads": self.getAdConfig()}
    end
end
