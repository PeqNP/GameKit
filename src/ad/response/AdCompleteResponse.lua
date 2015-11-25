--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

AdCompleteResponse = Class()
AdCompleteResponse.implements(BridgeResponseProtocol)

function AdCompleteResponse.new(self)
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
