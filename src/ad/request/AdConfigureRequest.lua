--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local AdConfigureRequest = Class()
AdConfigureRequest.implements("bridge.BridgeRequestProtocol")

function AdConfigureRequest.new(self)
    local config

    function self.init(_config)
        config = _config
    end

    function self.toDict()
        return {testDevices=table.concat(config.getTestDevices(), ","), automatic=config.isAutomatic(), orientation=config.getOrientation()}
    end
end

return AdConfigureRequest
