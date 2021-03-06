--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local System = require("shim.System")

local LongPressGesture = Class()

function LongPressGesture.new(self)
    function self.init(point, prevPoint, touch)
        self.point = point
        self.prevPoint = prevPoint
        self.touch = touch

        self.distance = System.GetDistance(point, prevPoint)
        self.angle = math.deg(math.atan2(prevPoint.y - point.y, prevPoint.x - point.x))
    end

    --[[ Flip the angle to produce the opposite of the computed angle. ]]--
    function self.reversedDegree()
        if self.angle >= 180 then
            return 180 - self.angle
        end
        return self.angle + 180
    end

    function self.reversedRadian()
        return self.angle * math.pi
    end

    function self.toNodeSpace(node)
        return LongPressGesture(node:convertToNodeSpace(self.point), node:convertToNodeSpace(self.prevPoint), self.direction)
    end

    function self.toWorldSpace(node)
        return LongPressGesture(node:convertToWorldSpace(self.point), node:convertToWorldSpace(self.prevPoint), self.direction)
    end
end

return LongPressGesture
