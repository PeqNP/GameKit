--[[ Provides an AdUnit, a structure that defines the version, id and tiers
     of a given Ad.

 @since 2015.05.27
 @copyright Upstart Illustration LLC

--]]

require "royal.AdTier"

AdUnit = Class()

--[[ Create a new AdUnit.

  @param id - id of the AdUnit
  @param tiers - the individual tiers that provide reward/config info, for a given state within the app.
--]]
function AdUnit.new(self, id, startdate, enddate, waitsecs, maxclicks, tiers)
    self.id = id
    self.startdate = startdate
    self.enddate = enddate
    self.waitsecs = waitsecs
    self.maxclicks = maxclicks

    function convertDictionaryToAdTiers(t)
        if not t then
            return {}
        end
        local ret = {}
        for _, dict in ipairs(t) do
            if dict.getClass then -- This is assumed to be an AdTier.
                table.insert(ret, dict)
            else
                table.insert(ret, AdTier(dict["id"], dict["url"], dict["reward"], dict["title"], dict["waitsecs"], dict["maxclicks"], dict["config"]))
            end
        end
        return ret
    end

    function self.setTiers(t)
        tiers = convertDictionaryToAdTiers(t)
    end

    function self.getTiers()
        return tiers
    end

    function self.isActive()
        local ctime = socket.gettime()
        if ctime < startdate or ctime > enddate then
            return false
        end

        local active = 0
        local totalClicks = 0
        for _, tier in ipairs(tiers) do
            totalClicks = totalClicks + tier.getNumClicks()
            if totalClicks >= maxclicks then
                return false
            end
            if not tier.isActive() then
                active = active + 1
            end
        end
        return active ~= #tiers
    end

    self.setTiers(tiers)
end
