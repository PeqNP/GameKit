--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Promise"
require "Error"

local Product = require("iap.Product")
local QueryRequest = require("iap.request.QueryRequest")
local QueryRequest = require("iap.request.PurchaseRequest")

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
        local promise = Promise()
        local response, call = bridge.purchase(PurchaseRequest(sku))
        call.done(function(response)
            promise.resolve(Transaction(response.getSKU(), response.getReceipt()))
        end)
        call.fail(function(resopnse)
            promise.reject(Error(0, response.getMessage()))
        end)
        return promise
    end

    function self.restorePurchases()
    end
end

return Manager
