TapGesture = Class()

function TapGesture.new(self, point)
    self.point = point

    function self.toWorldSpace(node)
        return TapGesture(node:convertToWorldSpace(self.point))
    end

    function self.toNodeSpace(node)
        return TapGesture(node:convertToNodeSpace(self.point))
    end
end
