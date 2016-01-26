-- 
-- @copyright 2015 Upstart Illustration LLC. All rights resevered.
--

local NetworkModule = Class()
NetworkModule.abstract(Protocol(
    -- Return the ID of the network.
    Method("getAdNetwork")
    -- Returns dictionary containing configuration.
  , Method("getConfig")
    -- Returns the ad network ID used by this module.
  , Method("getName")
))

function NetworkModule.new(self)
    local ads

    local function configureAds()
        for _, ad in ipairs(ads) do
            ad.setAdNetwork(self.getAdNetwork())
        end
    end

    function self.init(_ads)
        ads = _ads
        configureAds()
    end

    function self.getConfig()
        return {}
    end

    function self.getAds()
        return ads
    end
end

return NetworkModule
