--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.AdNetworkModule"

ChartboostNetwork = Class(AdNetworkModule)

function ChartboostNetwork.new(self, init)
    local appid
    local signature

    -- @param str appid
    -- @param Ad[] - List of ads
    function self.init(_appid, _signature, _ads)
        init(_ads)
        appid = _appid
        signature = _signature
    end

    function self.getName()
        return "Chartboost"
    end

    function getConfig()
        return {"network" = self.getName(), "appid": appid, "signature": signature, "ads": self.getAdConfig()}
    end
end
