--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "Promise"

local BridgeCall = Class(Promise)

function BridgeCall.new(self)
    local request

    function self.init(_request)
        request = _request
    end

    function self.getRequest()
        return request
    end
end

return BridgeCall
