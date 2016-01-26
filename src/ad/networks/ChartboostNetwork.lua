--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.Constants")
local NetworkModule = require("ad.NetworkModule")

local ChartboostNetwork = Class(NetworkModule)

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

    function self.getAdNetwork()
        return AdNetwork.Chartboost
    end

    function self.getName()
        return "Chartboost"
    end

    function self.getConfig()
        return {appid = appid, signature = signature}
    end
end

return ChartboostNetwork
