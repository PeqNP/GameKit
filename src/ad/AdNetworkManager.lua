--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

AdNetworkManager = Class()

function AdNetworkManager.new(self)
    local bridge
    local networks

    function self.init(_bridge, _networks)
        bridge = _bridge
        networks = _networks
    end

    function self.getNetworks()
        return networks
    end

    function self.registerNetworks()
        for _, network in ipairs(networks) do
            bridge.register()
        end
    end
end
