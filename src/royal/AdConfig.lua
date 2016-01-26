--[[ Provides configuration for Ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

local AdConfig = Class()

function AdConfig.new(self)
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
end

Singleton(AdConfig)

return AdConfig
