--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.Constants"
require "ad.AdNetworkModule"

AdMobNetwork = Class(AdNetworkModule)

function AdMobNetwork.new(self, init)
    function self.getAdNetwork()
        return AdNetwork.AdMob
    end

    function self.getName()
        return "AdMob"
    end

    function self.getConfig()
        return {network = self.getName(), ads = self.getAdConfig()}
    end
end
