--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

AdRegisterResponse = Class()

function AdRegisterResponse.new(self)
    local success
    local ads

    function self.init(_success, _ads)
        success = _success
        ads = _ads
    end

    function self.isSuccess()
        return success
    end

    function self.getAds()
        return ads
    end
end
