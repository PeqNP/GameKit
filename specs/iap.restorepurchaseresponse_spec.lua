require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

local RestorePurchaseResponse = require("iap.response.RestorePurchaseResponse")

describe("RestorePurchaseResponse", function()
    local subject

    context("when transactions and invalid SKUs are given", function()
        before_each(function()
            subject = RestorePurchaseResponse(10, "sku-1:receipt-1,sku-2:receipt-2")
        end)

        it("should parse transactions correctly", function()
            local transactions = subject.getTransactions()

            local product1 = transactions[1]
            assert.equal("sku-1", product1.getSKU())
            assert.equal("receipt-1", product1.getReceipt())

            local product2 = transactions[2]
            assert.equal("sku-2", product2.getSKU())
            assert.equal("receipt-2", product2.getReceipt())
        end)
    end)

    context("when no transactions or invalid SKUs given", function()
        before_each(function()
            subject = RestorePurchaseResponse(10)
        end)

        it("should return empty transactions array", function()
            local transactions = subject.getTransactions()
            assert.equal(0, #transactions)
        end)
    end)

    context("when no transactions or invalid SKUs given", function()
        before_each(function()
            subject = RestorePurchaseResponse(10, "")
        end)

        it("should return empty transactions array", function()
            local transactions = subject.getTransactions()
            assert.equal(0, #transactions)
        end)
    end)
end)
