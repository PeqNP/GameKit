--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeCall = Class(Promise)

function BridgeCall.new(self)
    local request

    function self.init(_request)
        request = _request
    end

    function self.getId()
        return request.getId()
    end

    function self.getRequest()
        return request
    end
end

