--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local Config = Class()

function Config.new(self)
    local testDevices
    local automatic
    local orientation

    function self.init(_testDevices, _automatic, _orientation)
        testDevices = _testDevices
        automatic = _automatic
        orientation = _orientation
    end

    function self.getTestDevices()
        return testDevices
    end

    function self.isAutomatic()
        return automatic
    end

    function self.getOrientation()
        return orientation
    end
end

return Config
