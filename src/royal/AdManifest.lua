--
-- Provides an AdManifest, a structure that defines the version and TTL
-- of AdUnits.
--
-- @copyright Upstart Illustration LLC
--

require "json"
require "Logger"

local AdUnit = require("royal.AdUnit")

local AdManifest = Class()

function AdManifest.new(self)
    local created
    local ttl
    local units

    function self.init(_created, _ttl, _units)
        created = _created
        ttl = _ttl
        units = _units
    end

    function self.getVersion()
        return version
    end

    function self.getCreated()
        return created
    end

    function self.getTtl()
        return ttl
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
        table.insert(units, AdUnit(dict["id"], dict["startdate"], dict["enddate"], dict["waitsecs"], dict["maxclicks"], dict["tiers"]))
    end
    local manifest = AdManifest(dict["created"], dict["ttl"], units)
end

--
-- Load config from cache. This step is necessary before downloading to ensure
-- that assets are not re-downloaded.
--
function AdManifest.loadFromFilepath(path)
    local fh = io.open(path, "r")
    if not fh then
        return nil
    end
    io.input(fh)
    local jsonStr = io.read("*all")
    io.close(fh)
    if not jsonStr or string.len(jsonStr) < 1 then
        Log.d("royal.Client:loadFromCache() - Cached royal.json file does not exist")
        return
    end
    local dict = json.decode(jsonStr)
    return AdManifest.fromDictionary(dict)
end

return AdManifest
