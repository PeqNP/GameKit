--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.Constants"
require "ad.AdNetworkModule"

VungleNetwork = Class(AdNetworkModule)

function VungleNetwork.new(self, init)
    local appid

    -- @param str appid
    -- @param Ad[] - List of ads
    function self.init(_appid, _ads)
        init(_ads)
        appid = _appid
    end

    function self.getAdNetwork()
        return AdNetwork.Vungle
    end

    function self.getName()
        return "Vungle"
    end

    function self.getConfig()
        return {appid = appid}
    end
end
