--
-- Provides an AdManifest, a structure that defines the version and TTL
-- of AdUnits.
--
-- @copyright Upstart Illustration LLC
--

require "Logger"

local AdUnit = require("royal.AdUnit")

local AdManifest = Class()

function AdManifest.new(self)
    local version
    local created
    local ttl
    local units

    function self.init(_version, _created, _ttl, _units)
        version = _version
        created = _created
        ttl = _ttl
        units = _units

        self.setAdUnits(units)
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

    local function convertDictionaryToAdUnits(u)
        if not u then
            return {}
        end
        local ret = {}
        for _, dict in ipairs(u) do
            if dict.getClass then -- This is assumed to be an AdUnit.
                table.insert(ret, dict)
            else
                table.insert(ret, AdUnit(dict["id"], dict["startdate"], dict["enddate"], dict["waitsecs"], dict["maxclicks"], dict["tiers"]))
            end
        end
        return ret
    end

    function self.setAdUnits(a)
        units = convertDictionaryToAdUnits(a)
    end

    function self.getAdUnits()
        return units
    end

    function self.isActive(epoch)
        return created >= epoch
    end
end

return AdManifest
