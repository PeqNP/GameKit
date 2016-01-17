--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeRequestProtocol"

local QueryRequest = Class()
QueryRequest.implements(BridgeRequestProtocol)

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
