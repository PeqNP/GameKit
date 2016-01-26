--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local Reward = Class()

function Reward.new(self, presented, clicked)
    function self.getPresentedAmount()
        return presented
    end

    function self.getClickedAmount()
        return clicked
    end
end

return Reward
