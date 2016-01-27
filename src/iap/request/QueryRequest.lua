--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local QueryRequest = Class()
QueryRequest.implements("bridge.BridgeRequestProtocol")

function QueryRequest.new(self)
    local skus

    function self.init(_skus)
        skus = _skus
    end

    -- BridgeRequestProtocol

    function self.toDict()
        return {skus=table.concat(skus, ",")}
    end
end

return QueryRequest
