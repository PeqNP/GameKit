--[[ Provides configuration for mediation.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

require "json"
require "mediation.MediationAdConfig"

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

function MediationConfig.fromJson(jsonBlob)
    local dict = json.decode(jsonBlob)
    local ads = {}
    for _, c in ipairs(dict["ads"]) do
        -- @fixme Should call MediationAdConfig.fromDictionary() class method from within MediationConfig.fromDictionary
        local config = MediationAdConfig.fromDictionary(c)
        table.insert(ads, config)
    end
    return MediationConfig(dict["version"], ads)
end
