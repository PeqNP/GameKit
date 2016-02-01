--
-- Provides payload for AdUnits. The payload is necessary to determine whether
-- an AdManifest is older than another. This is then used to download respective
-- assets.
--
-- @copyright Upstart Illustration LLC
--

require "json"
require "Logger"

local AdUnit = require("royal.AdUnit")

local AdManifest = Class()

function AdManifest.new(self)
    local created
    local units

    function self.init(_created, _units)
        created = _created
        units = _units
    end

    function self.getVersion()
        return version
    end

    function self.getCreated()
        return created
    end

    function self.setAdUnits(u)
        units = u
    end

    function self.getAdUnits()
        return units
    end

    function self.isActive(epoch)
        return created >= epoch
    end
end

function AdManifest.fromDictionary(dict)
    local units = {}
    for _, dict in ipairs(dict["units"]) do
        table.insert(units, AdTier(dict["id"], dict["startdate"], dict["enddate"], dict["url"], dict["reward"], dict["title"], dict["config"]))
    end
    local manifest = AdManifest(dict["created"], dict["ttl"], units)
end

--
-- Load config from cache. This step is necessary before downloading to ensure
-- that assets are not re-downloaded.
--
function AdManifest.loadFromFile(file)
    local jsonStr = file.getContents()
    if not jsonStr or string.len(jsonStr) < 1 then
        Log.d("royal.Client:loadFromFile() - Cached royal.json file does not exist")
        return nil
    end
    local dict = json.decode(jsonStr)
    return AdManifest.fromDictionary(dict)
end

return AdManifest
