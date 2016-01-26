
--[[ Provides an AdManifest, a structure that defines the version and TTL
     of AdUnits.

 @since 2015.05.27
 @copyright Upstart Illustration LLC

--]]

require "Logger"

local AdManifest = require("royal.AdManifest")

local AdManifestParser = Class()

function AdManifestParser.new(self)
    local classes

    function self.init(_classes)
        classes = _classes
        if not classes or #classes == 0 then
            Log.i("AdManifest: No classes specified! Falling back to base class AdManifest")
            classes = {AdManifest}
        end
    end

    function self.getClasses()
        return classes
    end

    function self.setClasses(c)
        classes = c
    end

    function self.fromDictionary(dict)
        local ver = dict["version"]
        local class = classes[ver]
        if not class then
            Log.s("AdManifest version (%s) is not supported!", ver)
            return nil
        end
        return class(ver, dict["created"], dict["ttl"], dict["units"])
    end
end

return AdManifestParser
