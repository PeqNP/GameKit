--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeRequest = Class(self)
BridgeRequest.abstract(Protocol(
    -- Returns a message that will be sent to the native layer.
    Method("getMessage")
))

function BridgeRequest.new(self)
end
