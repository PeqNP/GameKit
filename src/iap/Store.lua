--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Error = require("Error")
local Promise = require("Promise")
local Transaction = require("iap.Transaction")
local PurchaseRequest = require("iap.request.PurchaseRequest")

local Store = Class()

function Store.new(self)
    local bridge
    local tickets
    local products

    function self.init(_bridge, _tickets, _products)
        bridge = _bridge
        tickets = _tickets
        products = _products
    end

    function self.getBridge()
        return bridge
    end

    function self.getProducts()
        return products
    end

    local function getSKUForProductId(productId)
        for _, ticket in ipairs(tickets) do
            if productId == ticket.getProductId() then
                return ticket.getSKU()
            end
        end
        return nil
    end

    function self.getProductWithId(productId)
        local sku = getSKUForProductId(productId)
        if not sku then
            return nil
        end
        for _, product in ipairs(products) do
            if sku == product.getSKU() then
                return product
            end
        end
        return nil
    end

    function self.purchase(product)
        local promise = Promise()
        local response, call = bridge.purchase(PurchaseRequest(product.getSKU()))
        call.done(function(response)
            promise.resolve(Transaction(response.getSKU(), response.getReceipt()))
        end)
        call.fail(function(response)
            promise.reject(Error(0, response.getError()))
        end)
        return promise
    end

    function self.purchaseProductWithId(productId)
        local product = self.getProductWithId(productId)
        if not product then
            return nil
        end
        return self.purchase(product)
    end
end

return Store
