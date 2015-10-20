--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

AdReward = Class()

function AdReward.new(self, presented, clicked)
    function self.getPresentedAmount()
        return presented
    end

    function self.getClickedAmount()
        return clicked
    end
end
