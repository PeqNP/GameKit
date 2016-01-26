--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local BridgeRequestProtocol = Protocol(
    -- Returns a dictionary (key/value) representation of object that will be sent to native layer.
    Method("toDict")
)

return BridgeRequestProtocol
