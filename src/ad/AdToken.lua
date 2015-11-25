--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

AdToken = Class()

function AdToken.new(self)
    local token
    local zoneId

    function self.init(_token, _zoneId)
        token = _token
        zoneId = _zoneId
    end

    function self.getToken()
        return token
    end

    function self.getZoneId()
        return zoneId
    end
end
