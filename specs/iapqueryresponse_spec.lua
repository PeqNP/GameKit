require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

local QueryResponse = require("iap.response.QueryResponse")

describe("QueryResponse", function()
    local subject

    context("when products and invalid SKUs are given", function()
        before_each(function()
            subject = QueryResponse(10, "sku-1:Title:Description:$1.00,sku-2:Title-2:Description-2:$2.00", "sku-3,sku-4")
        end)

        it("should parse products correctly", function()
            local products = subject.getProducts()

            local product1 = products[1]
            assert.equal("sku-1", product1.getSKU())
            assert.equal("Title", product1.getTitle())
            assert.equal("Description", product1.getDescription())
            assert.equal("$1.00", product1.getPrice())

            local product2 = products[2]
            assert.equal("sku-2", product2.getSKU())
            assert.equal("Title-2", product2.getTitle())
            assert.equal("Description-2", product2.getDescription())
            assert.equal("$2.00", product2.getPrice())
        end)

        it("should parse SKUs correctly", function()
            assert.truthy(table.equals({"sku-3", "sku-4"}, subject.getInvalidSKUs()))
        end)
    end)

    context("when no products or invalid SKUs given", function()
        before_each(function()
            subject = QueryResponse(10)
        end)

        it("should return empty products array", function()
            local products = subject.getProducts()
            assert.equal(0, #products)
        end)

        it("should return empty invalid SKUs array", function()
            local skus = subject.getInvalidSKUs()
            assert.equal(0, #skus)
        end)
    end)

    context("when no products or invalid SKUs given", function()
        before_each(function()
            subject = QueryResponse(10, "", "")
        end)

        it("should return empty products array", function()
            local products = subject.getProducts()
            assert.equal(0, #products)
        end)

        it("should return empty invalid SKUs array", function()
            local skus = subject.getInvalidSKUs()
            assert.equal(0, #skus)
        end)
    end)
end)
