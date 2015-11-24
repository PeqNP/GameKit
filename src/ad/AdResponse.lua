--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

AdResponse = Class()
AdResponse.implements(BridgeResponseProtocol)

function AdResponse.new(self)
    local id
    local state
    local reward
    local clicked
    local _error

    function self.init(_id, _state, reward, clicked, _err)
        id = _id
        reward = reward
        clicked = clicked
        state = _state
        _error = _err
    end

    -- @todo hasError() -- Anything other than an error state.

    function self.getState()
        return state
    end

    -- @todo getReward()
    -- @todo isClicked()

    function self.getError()
        return _error
    end

    -- BridgeResponseProtocol

    function self.getId()
        return id
    end
end
