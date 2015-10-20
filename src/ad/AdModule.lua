-- 
-- @copyright 2015 Upstart Illustration LLC. All rights resevered.
--

require "ad.AdRequest"

AdModule = Class()

function AdModule.new()
    local self = {}

    function self.getAdType()
        assert(false, "AdModule.getAdType() MUST be over-ridden!")
    end

    function self.getNetworkId()
        assert(false, "AdModule.getAdType() MUST be over-ridden!")
    end

    function self.generateAdRequest()
        return AdRequest()
    end

    return self
end
