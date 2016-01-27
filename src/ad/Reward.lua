--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local Reward = Class()

function Reward.new(self)
    local presented
    local clicked

    function self.init(_presented, _clicked)
        presented = _presented
        clicked = _clicked
    end

    function self.getPresentedAmount()
        return presented
    end

    function self.getClickedAmount()
        return clicked
    end
end

return Reward
