--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

local PostResponse = Class()
PostResponse.implements(BridgeResponseProtocol)

function PostResponse.new(self)
    local id
    local success
    local errorCode
    local _error

    function self.init(_id, _success, _errorCode, __error)
        id = _id
        success = _success
        errorCode = _errorCode
        _error = __error
    end

    function self.getId()
        return id
    end

    function self.isSuccess()
        return success
    end

    function self.getCode()
        return errorCode
    end

    function self.getError()
        return _error
    end
end

return PostResponse
