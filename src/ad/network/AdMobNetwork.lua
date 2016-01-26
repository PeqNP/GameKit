--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.Constants")
local NetworkModule = require("ad.NetworkModule")

local AdMobNetwork = Class(NetworkModule)

function AdMobNetwork.new(self, init)
    function self.getAdNetwork()
        return AdNetwork.AdMob
    end

    function self.getName()
        return "AdMob"
    end

    function self.getConfig()
        return {}
    end
end

return AdMobNetwork
