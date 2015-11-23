--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeCall = Class(Promise)

function BridgeCall.new(self)
    local request
    local response

    function self.init(_request, _response)
        request = _request
        response = _response
    end

    function self.getId()
        return request.getId()
    end

    function self.getRequest()
        return request
    end

    function self.getResponse()
        return response
    end
end

