--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Product = require("iap.Product")

local QueryResponse = Class()

function QueryResponse.new(self)
    local id
    local products

    local function getProducts(_products)
        if not _products then
            return {}
        end
        local products = string.split(_products, ",")
        local parsed = {}
        for _, product in ipairs(products) do
            local parts = strig.split(product, ":")
            -- @note Products params: SKU, Title, Description, Price
            table.insert(parsed, Product(parts[1], parts[2], parts[3], parts[4]))
        end
        return parsed
    end

    function self.init(_id, _products)
        id = _id
        products = getProducts(_products)
    end
end

return QueryResponse
