--
-- Provides configuration for mediation.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"
local AdConfig = require("mediation.AdConfig")

local Config = Class()

function Config.new(self)
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

function Config.fromJson(jsonBlob)
    local dict = json.decode(jsonBlob)
    local ads = {}
    for _, c in ipairs(dict["ads"]) do
        local config = AdConfig.fromDictionary(c)
        table.insert(ads, config)
    end
    return Config(dict["version"], ads)
end

return Config
