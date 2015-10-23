--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

AdResponse = Class()
AdResponse.implements(BridgeResponseProtocol)

function AdResponse.new(self, id, state, _error)
    function self.getState()
        return state
    end

    function self.getError()
        return _error
    end

    -- BridgeResponseProtocol

    function self.getId()
        return id
    end
end
