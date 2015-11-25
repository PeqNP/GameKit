--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

AdCacheResponse = Class()
AdCacheResponse.implements(BridgeResponseProtocol)

function AdCacheResponse.new(self)
    local id
    local _error

    function self.init(_id, _err)
        id = _id
        _error = _err
    end

    function self.isFailure()
        return _error and true or false
    end

    function self.getError()
        return _error
    end

    -- BridgeResponseProtocol

    function self.getId()
        return id
    end
end
