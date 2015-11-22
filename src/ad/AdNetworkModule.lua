-- 
-- @copyright 2015 Upstart Illustration LLC. All rights resevered.
--

AdNetworkModule = Class()
AdNetworkModule.abstract(Protocol(
    -- Return the ID of the network
    Method("getAdNetwork")
    -- Return config used to initialize network module.
  , Method("getConfig")
    -- Returns the ad network ID used by this module.
  , Method("getName")
))

function AdNetworkModule.new(self)
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

    function self.getAdConfig()
        -- @todo
    end

    function self.getAds()
        return ads
    end
end
