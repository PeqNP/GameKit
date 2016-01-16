--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

local TransactionResponse = Class()
TransactionResponse.implements(BridgeResponseProtocol)

function TransactionResponse.new(self)
    local id
    local productId
    local receipt

    function self.init(_id, _productId, _receipt)
        id = _id
        productId = _productId
        receipt = _receipt
    end

    function self.getId()
        return id
    end

    function self.getProductId()
        return productId
    end

    function self.getReceipt()
        return receipt
    end
end

return TransactionResponse
