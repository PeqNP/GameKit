--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeRequest"

AdRegisterNetworkRequest = Class(BridgeRequest)

function AdRegisterNetworkRequest.new(self)
    local network

    function self.init(_network)
        network = _network
    end

    -- BridgeRequestProtocol

    local function getAds()
        local ads = network.getAds()
        local values = {}
        for _, ad in ipairs(ads) do
            table.insert(values, {type=ad.getAdType(), zoneid=ad.getZoneId()})
        end
        return values
    end

    function self.toDict()
        local config = network.getConfig()
        config['network'] = network.getName()
        config['ads'] = getAds()
        return config
    end
end
