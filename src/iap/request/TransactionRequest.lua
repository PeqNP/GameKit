--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeRequest"

local TransactionRequest = Class(BridgeRequest)

function TransactionRequest.new(self)
    local productId

    function self.init(_productId)
        productId = _productId
    end

    function self.toDict()
        return {productid=productId}
    end
end

return TransactionRequest
