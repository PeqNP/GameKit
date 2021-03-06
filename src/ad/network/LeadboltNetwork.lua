--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require("ad.Constants")
local NetworkModule = require("ad.NetworkModule")

local LeadboltNetwork = Class(NetworkModule)

function LeadboltNetwork.new(self, init)
    local appid

    -- @param str appid
    -- @param Ad[] - List of ads
    function self.init(_appid, _ads)
        init(_ads)
        appid = _appid
    end

    function self.getAdNetwork()
        return AdNetwork.Leadbolt
    end

    function self.getName()
        return "Leadbolt"
    end

    function self.getConfig()
        return {appid = appid}
    end
end

return LeadboltNetwork
