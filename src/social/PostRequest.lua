--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local PostRequest = Class()
PostRequest.implements("bridge.BridgeRequestProtocol")

function PostRequest.new(self)
    local service
    local message
    local image
    local link

    function self.init(_service, _message, _image, _link)
        service = _service
        message = _message
        image = _image
        link = _link
    end

    -- BridgeRequestProtocol

    function self.toDict()
        return {service=service, message=message, image=image, link=link}
    end
end

return PostRequest
