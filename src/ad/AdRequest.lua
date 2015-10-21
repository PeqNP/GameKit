--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.Constants"

AdRequest = Class()

-- ID used to track new ad requests.
local _id = 0

function get_next_id()
    _id = _id + 1
    return _id
end

function AdRequest.new(self, adNetwork, adType, zone, reward, _state)
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

    function self.getAdNetwork()
        return adNetwork
    end

    function self.getAdType()
        return adType
    end

    function self.getZone()
        return zone
    end

    function self.isComplete()
        return table.contains({AdState.Complete, AdState.Clicked}, state)
    end
end
