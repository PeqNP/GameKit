LongPressGesture = Class()

function LongPressGesture.new(self, point, prevPoint, touch)
    self.point = point
    self.prevPoint = prevPoint
    self.touch = touch

    self.distance = cu.getDistance(point, prevPoint)
    self.angle = math.deg(math.atan2(prevPoint.y - point.y, prevPoint.x - point.x))

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
