--[[ Provides an AdManifest version 1.

 @since 2015.06.03
 @copyright Upstart Illustration LLC

--]]

require "royal.AdManifest"

AdManifestV1 = Class()

--[[ Create a new AdManifest.

  @param version - version of the manifest
  @param ttl - the length of time this manifest will locally before the manifest is queried again.
--]]
function AdManifestV1.new()
    local self = AdManifest()

    local _parseJson = self.parseJson
    function self.parseJson(json)
        local dict = _parseJson(json)
        -- @todo
    end

    return self
end
