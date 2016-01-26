--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local TapGesture = Class()

function TapGesture.new(self)
    function self.init(point)
        self.point = point
    end

    function self.toWorldSpace(node)
        return TapGesture(node:convertToWorldSpace(self.point))
    end

    function self.toNodeSpace(node)
        return TapGesture(node:convertToNodeSpace(self.point))
    end
end

return TapGesture
