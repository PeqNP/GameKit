--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local IAPManager = Class()

function IAPManager.new(self)
    local bridge

    function self.init(_bridge)
        bridge = _bridge
    end

    function self.querySKUs(skus)
        return bridge.
        local promise = Promise()
        return promise
    end

    function self.purchaseSKU(sku)
    end

    function self.restorePurchases()
    end
end

return IAPManager
