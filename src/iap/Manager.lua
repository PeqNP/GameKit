--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Promise"
require "Error"

local Store = require("iap.Store")
local Product = require("iap.Product")
local Transaction = require("iap.Transaction")
local QueryRequest = require("iap.request.QueryRequest")
local PurchaseRequest = require("iap.request.PurchaseRequest")

local Manager = Class()

function Manager.new(self)
    local bridge

    function self.init(_bridge)
        bridge = _bridge
    end

    local function getSKUs(tickets)
        local skus = {}
        if not tickets then
            Log.w("Getting SKUs when no tickts given!")
            return skus
        end
        for _, ticket in ipairs(tickets) do
            table.insert(skus, ticket.getSKU())
        end
        return skus
    end

    -- @param string[] - List of SKUs used to query for respective products.
    function self.fetchProducts(tickets)
        local promise = Promise()
        local skus = getSKUs(tickets)
        local response, call = bridge.query(QueryRequest(skus))
        call.done(function(response)
            promise.resolve(Store(bridge, tickets, response.getProducts()), response.getInvalidSKUs())
        end)
        call.fail(function(response)
            promise.reject(response)
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
end

return Manager
