--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local Ad = Class()

function Ad.new(self)
    local adNetwork
    local adType
    local zoneId
    local location
    local adId

    function self.init(_adType, _zoneId, _location)
        adType = _adType
        zoneId = _zoneId
        location = _location
    end

    function self.getAdType()
        return adType
    end

    function self.getZoneId()
        return zoneId
    end

    function self.getLocation()
        return location
    end

    function self.setAdNetwork(a)
        adNetwork = a
    end

    function self.getAdNetwork()
        return adNetwork
    end

    function self.setAdId(id)
        adId = id
    end

    function self.getAdId()
        return adId
    end
end

return Ad
