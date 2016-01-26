--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

local AdCompleteResponse = Class(BridgeResponse)

function AdCompleteResponse.new(self, init)
    local reward
    local clicked

    function self.init(_success, _id, _reward, _clicked, _err)
        init(_success, _id, _err)
        reward = _reward
        clicked = _clicked
    end

    function self.getReward()
        return reward
    end

    function self.isClicked()
        return clicked
    end
end

return AdCompleteResponse
