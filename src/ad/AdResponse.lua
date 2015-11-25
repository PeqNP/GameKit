--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

AdResponse = Class()
AdResponse.implements(BridgeResponseProtocol)

function AdResponse.new(self)
    local id
    local reward
    local clicked
    local _error

    function self.init(_id, reward, clicked, _err)
        id = _id
        reward = reward
        clicked = clicked
        _error = _err
    end

    function self.isFailure()
    end

    function self.getReward()
    end

    function self.clicked()
    end

    function self.getError()
        return _error
    end

    -- BridgeResponseProtocol

    function self.getId()
        return id
    end
end
