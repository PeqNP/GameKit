TapGesture = Class()

function TapGesture.new(point)
    local self = {}
    self.point = point

    function self.toWorldSpace(node)
        return TapGesture(node:convertToWorldSpace(self.point))
    end

    function self.toNodeSpace(node)
        return TapGesture(node:convertToNodeSpace(self.point))
    end

    return self
end
