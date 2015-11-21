--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.Constants"
require "ad.AdNetworkModule"

iAdNetwork = Class(AdNetworkModule)

function iAdNetwork.new(self, init)
    function self.getName()
        return "iAd"
    end

    function self.getAdNetwork()
        return AdNetwork.iAd
    end

    function self.getConfig()
        return {network = self.getName(), ads = self.getAdConfig()}
    end
end
