
--[[ Provides an AdManifest, a structure that defines the version and TTL
     of AdUnits.

 @since 2015.05.27
 @copyright Upstart Illustration LLC

--]]

require "ad.AdManifest"

AdManifestParser = Class()

function AdManifestParser.new(classes)
    local self = {}

    if not classes or #classes == 0 then
        --Log.w("AdManifest: No classes specified! Falling back to base class AdManifest")
        classes = {AdManifest}
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
        return class.new(ver, dict["created"], dict["ttl"], dict["units"])
    end

    return self
end

Singleton(AdManifestParser)
