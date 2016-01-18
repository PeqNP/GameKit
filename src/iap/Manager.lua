--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Promise"
require "Error"

local Product = require("iap.Product")
local Transaction = require("iap.Transaction")
local QueryRequest = require("iap.request.QueryRequest")
local PurchaseRequest = require("iap.request.PurchaseRequest")

local Manager = Class()

function Manager.new(self)
    local bridge
    local products = {}

    function self.init(_bridge)
        bridge = _bridge
    end

    -- @param string[] - List of SKUs used to query for respective products.
    function self.queryProducts(skus)
        local promise = Promise()
        local response, call = bridge.query(QueryRequest(skus))
        call.done(function(response)
            local _products = response.getProducts()
            for product in ipairs(_products) do
                table.insert(products, product)
            end
            promise.resolve(_products, response.getInvalidSKUs())
        end)
        call.fail(function(response)
            promise.reject(response)
        end)
        return promise
    end

    function self.purchase(sku)
        local promise = Promise()
        local response, call = bridge.purchase(PurchaseRequest(sku))
        call.done(function(response)
            promise.resolve(Transaction(response.getSKU(), response.getReceipt()))
        end)
        call.fail(function(response)
            promise.reject(Error(0, response.getError()))
        end)
        return promise
    end

    function self.restorePurchases()
        local promise = Promise()
        local response, call = bridge.restore()
        call.done(function(response)
            promise.resolve(response.getTransactions())
        end)
        call.fail(function(response)
            promise.reject(Error(0, response.getError()))
        end)
        return promise
    end

    function self.hasProducts()
        if #products > 0 then
            return true
        end
        return false
    end
end

return Manager
