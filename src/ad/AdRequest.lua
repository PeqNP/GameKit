--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeRequest"
require "ad.Constants"

AdRequest = Class(BridgeRequest)

function AdRequest.new(self)
    local adNetwork
    local ad
    local state

    function self.init(_adNetwork, _ad, _state)
        adNetwork = _adNetwork
        ad = _ad
        state = _state and _state or AdState.Initial
    end

    function self.setState(s)
        state = s
    end

    function self.getState()
        return state
    end

    function self.getAdNetwork()
        return adNetwork
    end

    function self.getAdType()
        return ad.getAdType()
    end

    function self.getZoneId()
        return ad.getZoneId()
    end

    function self.getReward()
        return ad.getReward()
    end

    function self.isComplete()
        return table.contains({AdState.Complete, AdState.Clicked}, state)
    end

    -- BridgeRequest

    function self.getMessage()
        -- @todo
    end
end
