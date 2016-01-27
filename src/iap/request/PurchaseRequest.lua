--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local PurchaseRequest = Class()
PurchaseRequest.implements("bridge.BridgeRequestProtocol")

function PurchaseRequest.new(self)
    local sku

    function self.init(_sku)
        sku = _sku
    end

    -- BridgeRequestProtocol

    function self.toDict()
        return {sku=sku}
    end
end

return PurchaseRequest
