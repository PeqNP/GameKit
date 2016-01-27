--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local AdCacheResponse = Class("bridge.BridgeResponse")

function AdCacheResponse.new(self, init)
    local reward

    function self.init(_success, _id, _reward, _err)
        init(_success, _id, _err)
        reward = _reward
    end

    function self.getReward()
        return reward
    end
end

return AdCacheResponse
