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

    function self.init(_id, _reward, _clicked, _err)
        id = _id
        reward = _reward
        clicked = _clicked
        _error = _err
    end

    function self.isSuccess()
        if _error then
            return false
        end
        return true
    end

    function self.getReward()
        return reward
    end

    function self.isClicked()
        return clicked
    end

    function self.getError()
        return _error
    end

    -- BridgeResponseProtocol

    function self.getId()
        return id
    end
end
