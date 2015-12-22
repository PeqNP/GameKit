--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeRequest = Class(self)
BridgeRequest.abstract(Protocol(
    -- Returns a dictionary (key/value) representation of object that will be sent to native layer.
    Method("toDict")
))

function BridgeRequest.new(self)
    local id

    function self.setId(_id)
        id = _id
    end

    function self.getId()
        return id
    end
end
