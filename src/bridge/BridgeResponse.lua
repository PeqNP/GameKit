--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local BridgeResponse = Class()
BridgeResponse.implements("bridge.BridgeResponseProtocol")

function BridgeResponse.new(self)
    local success
    local id
    local _error

    function self.init(_success, _id, _e)
        if _success == 1 or _success == true then
            success = true
        else
            success = false
        end
        id = _id
        _error = _e
    end

    function self.isSuccess()
        return success
    end

    function self.getId()
        return id
    end

    function self.getError()
        return _error
    end
end

return BridgeResponse
