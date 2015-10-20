-- 
-- @copyright 2015 Upstart Illustration LLC. All rights resevered.
--

AdModule = Class()

function AdModule.new(self)

    local devices

    function self.setDevices(d)
        devices = d
    end

    function self.getDevices()
        return devices
    end
end
