--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeRequestProtocol"

local TransactionRequest = Class()
TransactionRequest.implements(BridgeRequestProtocol)

function TransactionRequest.new(self)
    local productId

    function self.init(_productId)
        productId = _productId
    end

    -- BridgeRequestProtocol

    function self.toDict()
        return {productid=productId}
    end
end

return TransactionRequest
