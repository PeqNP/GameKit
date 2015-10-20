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

function AdRequest.new()
    local self = {}

    local id = get_next_id()
    local state = AdState.Initial

    function self.getId()
        return id
    end

    function self.setState(s)
        state = s
    end

    function self.getState()
        return state
    end

    return self
end
