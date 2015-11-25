--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

BridgeResponse = Class()

function BridgeResponse.new(self)
    local success
    local _error

    function self.init(_success, _e)
        success = _success
        _error = _e
    end

    function self.isSuccess()
        return success
    end

    function self.getError()
        return _error
    end
end
