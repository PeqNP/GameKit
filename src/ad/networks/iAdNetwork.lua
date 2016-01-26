--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.Constants")
local NetworkModule = require("ad.AdNetworkModule")

local iAdNetwork = Class(NetworkModule)

function iAdNetwork.new(self, init)
    function self.getName()
        return "iAd"
    end

    function self.getAdNetwork()
        return AdNetwork.iAd
    end

    function self.getConfig()
        return {}
    end
end

return iAdNetwork
