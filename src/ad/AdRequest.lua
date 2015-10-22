--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "ndk.NDKRequestProtocol"
require "ad.Constants"

AdRequest = Class()
AdRequest.implements(NDKRequestProtocol)

-- ID used to track new ad requests.
local _id = 0

function get_next_id()
    _id = _id + 1
    return _id
end

function AdRequest.new(self, adModule, _state)
    local id = get_next_id()
    local state = _state and _state or AdState.Initial

    function self.getId()
        return id
    end

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

    -- NDKRequestProtocol

    function self.getMessage()
    end
end
