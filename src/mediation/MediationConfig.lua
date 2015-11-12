--[[ Provides configuration for mediation.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

MediationConfig = Class()

function MediationConfig.new(self)
    local version
    local ads

    function self.init(_version, _ads)
        version = _version
        ads = _ads
    end

    function self.getVersion()
        return version
    end

    function self.getAds()
        return ads
    end
end
