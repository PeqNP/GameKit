--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.AdNetworkModule"

AdColonyNetwork = Class(AdNetworkModule)

function AdColonyNetwork.new(self, init)
    local appid

    -- @param str appid - The AdColony app ID
    -- @param Ad[] - List of ads
    function self.init(_appid, _ads)
        init(_ads)
        appid = _appid
    end

    function self.getName()
        return "AdColony"
    end

    function getConfig()
        return {"network" = self.getName(), "appid": appid, "ads": self.getAdConfig()}
    end
end
