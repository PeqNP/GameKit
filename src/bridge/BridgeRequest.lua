--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeRequest = Class(self)
BridgeRequest.abstract(Protocol(
    -- Returns the ID that can be used to match corresponding response.
    Method("getId")
    -- Returns a dictionary (key/value) representation of object that will be sent to native layer.
  , Method("toDict")
))

function BridgeRequest.new(self)
end
