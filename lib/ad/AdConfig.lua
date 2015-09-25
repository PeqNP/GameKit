--[[ Provides configuration for Ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

AdConfig = Class()

function AdConfig.new()
    local self = {}

    local path
    local appId
    local appToken
    local imageVariant = "sd"

    function self.setBasePath(p)
        path = p
    end

    function self.getBasePath()
        return path
    end

    function self.getPath(p)
        return path .. p
    end

    function self.setImageVariant(v)
        imageVariant = v
    end

    function self.getImageVariant()
        return imageVariant
    end

    return self
end

Singleton(AdConfig)
