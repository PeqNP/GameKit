--[[ Provides configuration for mediation.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

MediationConfig = Class()

function MediationConfig.new(version, ads)
    local self = {}

    function self.getVersion()
        return version
    end

    function self.getAds()
        return ads
    end

    return self
end
