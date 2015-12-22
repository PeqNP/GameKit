--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeResponseProtocol= Protocol(
    Method("getId")
)

BridgeResponse = Class()

function BridgeResponse.new(self)
    local success
    local _error

    function self.init(_success, _e)
        if _success == 1 or _success == true then
            success = true
        else
            success = false
        end
        _error = _e
    end

    function self.isSuccess()
        return success
    end

    function self.getError()
        return _error
    end
end
