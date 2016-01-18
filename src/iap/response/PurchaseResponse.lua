--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

local PurchaseResponse = Class()
PurchaseResponse.implements(BridgeResponseProtocol)

function PurchaseResponse.new(self)
    local id
    local sku
    local receipt

    function self.init(_id, _sku, _receipt)
        id = _id
        sku = _sku
        receipt = _receipt
    end

    function self.getId()
        return id
    end

    function self.getSKU()
        return sku
    end

    function self.getReceipt()
        return receipt
    end
end

return PurchaseResponse
