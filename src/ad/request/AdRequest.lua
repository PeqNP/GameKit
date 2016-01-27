--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.Constants"

local AdRequest = Class()
AdRequest.implements("bridge.BridgeRequestProtocol")

function AdRequest.new(self)
    local ad
    local state
    local reward

    function self.init(_ad, _state)
        ad = _ad
        state = _state and _state or AdState.Initial
    end

    function self.setState(s)
        state = s
    end

    function self.getState()
        return state
    end

    function self.setReward(r)
        reward = r
    end

    function self.getReward()
        return reward
    end

    function self.getAd()
        return ad
    end

    function self.getAdNetwork()
        return ad.getAdNetwork()
    end

    function self.getAdType()
        return ad.getAdType()
    end

    function self.getZoneId()
        return ad.getZoneId()
    end

    function self.getAdId()
        return ad.getAdId()
    end

    function self.isComplete()
        return table.contains({AdState.Complete, AdState.Clicked}, state)
    end

    -- BridgeRequestProtocol

    function self.toDict()
        return {adid=ad.getAdId()}
    end
end

return AdRequest
