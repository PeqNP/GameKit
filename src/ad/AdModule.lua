-- 
-- @copyright 2015 Upstart Illustration LLC. All rights resevered.
--

AdModule = Class()
AdModule.abstract(Protocol(
    -- Return config used to initialize network module.
    Method("getConfig")
    -- Returns the ad network ID used by this module.
  , Method("getAdNetwork")
    -- Returns the name of the ad network used by this module.
  , Method("getAdNetworkName")
    -- Returns the AdType
  , Method("getAdType")
))

function AdModule.new(self)
    local devices

    function self.setDevices(d)
        devices = d
    end

    function self.getDevices()
        return devices
    end
end
