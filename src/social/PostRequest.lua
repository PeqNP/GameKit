--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeRequestProtocol"

local PostRequest = Class()
PostRequest.implements(BridgeRequestProtocol)

function PostRequest.new(self)
    local service
    local message
    local image
    local resource

    function self.init(_service, _message, _image, _resource)
        service = _service
        message = _message
        image = _image
        resource = _resource
    end

    -- BridgeRequestProtocol

    function self.toDict()
        return {service=service, message=message, image=image, resource=resource}
    end
end

return PostRequest
