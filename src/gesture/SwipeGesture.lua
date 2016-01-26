--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local SwipeGesture = Class()

function SwipeGesture.new(self)
    function self.init(start, stop, direction)
        self.start = start
        self.stop = stop
        self.direction = direction
        
        self.distance = cc.pDot(start, stop)
        self.magntidue = math.sqrt(self.distance)
        self.angle = cc.pGetAngle(start, stop)

        -- local slideMulitplier = self.magnitude / 200;
        -- local slideFactor = 0.1 * slideMultiplier
    end
end

return SwipeGesture
