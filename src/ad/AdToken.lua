--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

AdToken = Class()

function AdToken.new(self)
    local adId
    local zoneId

    function self.init(_adId, _zoneId)
        adId = _adId
        zoneId = _zoneId
    end

    function self.getAdId()
        return adId
    end

    function self.getZoneId()
        return zoneId
    end
end
