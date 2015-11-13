--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

AdResponse = Class()
AdResponse.implements(BridgeResponseProtocol)

function AdResponse.new(self)
    local id
    local state
    local _error

    function self.init(_id, _state, _err)
        id = _id
        state = _state
        _error = _err
    end

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
