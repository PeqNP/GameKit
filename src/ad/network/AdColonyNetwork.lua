--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.Constants")
local NetworkModule = require("ad.NetworkModule")

local AdColonyNetwork = Class(NetworkModule)

function AdColonyNetwork.new(self, init)
    local appid

    -- @param str appid - The AdColony app ID
    -- @param Ad[] - List of ads
    function self.init(_appid, _ads)
        init(_ads)
        appid = _appid
    end

    function self.getAdNetwork()
        return AdNetwork.AdColony
    end

    function self.getName()
        return "AdColony"
    end

    function self.getConfig()
        return {appid = appid}
    end
end

return AdColonyNetwork
