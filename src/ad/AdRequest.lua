--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeRequest"
require "ad.Constants"

AdRequest = Class(BridgeRequest)

function AdRequest.new(self, adModule, _state)
    local state = _state and _state or AdState.Initial

    function self.setState(s)
        state = s
    end

    function self.getState()
        return state
    end

    function self.getAdModule()
        return adModule
    end

    function self.getAdNetwork()
        return adModule.getAdNetwork()
    end

    function self.getAdType()
        return adModule.getAdType()
    end

    function self.getZone()
        return adModule.getZone()
    end

    function self.getReward()
        return adModule.getReward()
    end

    function self.isComplete()
        return table.contains({AdState.Complete, AdState.Clicked}, state)
    end

    -- BridgeRequest

    function self.getMessage()
        -- @todo
    end
end
