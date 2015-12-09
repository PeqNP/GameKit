--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeRequest = Class(self)
BridgeRequest.abstract(Protocol(
    -- Returns a dictionary (key/value) representation of object that will be sent to native layer.
    Method("toDict")
))

local serial_id = 0
local function get_next_id()
    serial_id = serial_id + 1
    return serial_id
end

function BridgeRequest.new(self)
    local id = get_next_id()

    function self.getId()
        return id
    end
end
