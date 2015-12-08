--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

Ad = Class()

function Ad.new(self)
    local adNetwork
    local adType
    local zoneId
    local reward
    local token

    function self.init(_adType, _zoneId)
        adType = _adType
        zoneId = _zoneId
    end

    function self.getAdType()
        return adType
    end

    function self.getZoneId()
        return zoneId
    end

    function self.setAdNetwork(a)
        adNetwork = a
    end

    function self.getAdNetwork()
        return adNetwork
    end

    function self.setToken(t)
        token = t
    end

    function self.getToken()
        return token
    end
end
