--
-- @since 2015 Upstart Illustration LLC. All rights reserved.
--

-- ID used to track new bridge requests.
local _id = 0

local function get_next_request_id()
    _id = _id + 1
    return _id
end

BridgeRequest = Class(self)
BridgeRequest.abstract(Protocol(
    -- Returns a message that will be sent to the native layer.
    Method("getMessage")
))

function BridgeRequest.new(self)
    local id = get_next_request_id()

    function self.getId()
        return id
    end
end
