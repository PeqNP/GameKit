--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Promise"

local Product = require("iap.Product")
local QueryRequest = require("iap.request.QueryRequest")

local Manager = Class()

function Manager.new(self)
    local bridge

    function self.init(_bridge)
        bridge = _bridge
    end

    function self.querySKUs(skus)
        local promise = Promise()
        local response, call = bridge.query(QueryRequest(skus))
        call.done(function(response)
            promise.resolve(response.getProducts(), response.getInvalidSKUs())
        end)
        call.fail(function(response)
            promise.reject(response)
        end)
        return promise
    end

    function self.purchaseSKU(sku)
    end

    function self.restorePurchases()
    end
end

return Manager
