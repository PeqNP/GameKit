--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponseProtocol"

local Product = require("iap.Product")

local QueryResponse = Class()
QueryResponse.implements(BridgeResponseProtocol)

function QueryResponse.new(self)
    local id
    local products
    local invalidSKUs

    local function getProducts(_products)
        if not _products or _products == "" then
            return {}
        end
        local products = string.split(_products, ",")
        local parsed = {}
        for _, product in ipairs(products) do
            local parts = string.split(product, ":")
            -- @note Products params: SKU, Title, Description, Price
            table.insert(parsed, Product(parts[1], parts[2], parts[3], parts[4]))
        end
        return parsed
    end

    local function getInvalidSKUs(_skus)
        if not _skus or _skus == "" then
            return {}
        end
        local skus = string.split(_skus, ",")
        local parsed = {}
        for _, sku in ipairs(skus) do
            table.insert(parsed, sku)
        end
        return parsed
    end

    function self.init(_id, _products, _invalidSKUs)
        id = _id
        products = getProducts(_products)
        invalidSKUs = getInvalidSKUs(_invalidSKUs)
    end

    function self.getId()
        return id
    end

    function self.getProducts()
        return products
    end

    function self.getInvalidSKUs()
        return invalidSKUs
    end
end

return QueryResponse
