--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Promise"
require "iap.Product"

local Manager = Class()

function Manager.new(self)
    local bridge

    function self.init(_bridge)
        bridge = _bridge
    end

    function self.querySKUs(skus)
        local promise = Promise()
        local response, call = bridge.query(TransactionQueryRequest(skus))
        response.done(function(response)
            promise.done(response.getProducts(), response.getInvalid())
        end)
        response.fail(function(response)
            promise.fail(response)
        end)
        return promise
    end

    function self.purchaseSKU(sku)
    end

    function self.restorePurchases()
    end
end

return Manager
