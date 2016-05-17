--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local ConfigureRequest = Class()
ConfigureRequest.implements("bridge.BridgeRequestProtocol")

function ConfigureRequest.new(self)
    local service
    local config

    function self.init(_service, _config)
        service = _service
        config = _config
    end

    -- BridgeRequestProtocol

    function self.toDict()
        return {service=service, config=config}
    end
end

return ConfigureRequest

