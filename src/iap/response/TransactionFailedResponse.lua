--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

local TransactionFailedResponse = Class()
TransactionFailedResponse.implements(BridgeResponseProtocol)

function TransactionFailedResponse.new(self)
    local id
    local _error

    function self.init(_id, _e)
        id = _id
        _error = _e
    end

    function self.getId()
        return id
    end

    function self.getError()
        return _error
    end
end

return TransactionFailedResponse
