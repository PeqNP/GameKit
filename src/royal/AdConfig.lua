--
-- Provides configuration for Ads.
--
-- FIXME: _file should simply use LuaFile.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local LuaFile = require("LuaFile")

local AdConfig = Class()

function AdConfig.new(self)
    local basepath
    local appId
    local appToken
    local imageVariant = "sd"

    function self.init(_basepath)
        basepath = _basepath
    end

    function self.getBasePath()
        return basepath
    end

    function self.getPath(p)
        return basepath .. p
    end

    function self.setImageVariant(v)
        imageVariant = v
    end

    function self.getImageVariant()
        return imageVariant
    end

    function self.getImageFilename()
        return "royal.png"
    end

    function self.getPlistFilename()
        return "royal.plist"
    end

    function self.getConfigFilename()
        return "royal.json"
    end

    function self.getImageFilepath()
        return self.getPath(self.getImageFilename())
    end

    -- Returns the path where the plist file will be/was saved locally.
    function self.getPlistFilepath()
        return self.getPath(self.getPlistFilename())
    end

    function self.getConfigFilepath()
        return self.getPath(self.getConfigFilename())
    end

    function self.write(filename, contents, mode)
        LuaFile.write(self.getPath(filename), contents, mode)
    end

    function self.read(filename, mode)
        return LuaFile.read(self.getPath(filename), mode)
    end
end

return AdConfig
