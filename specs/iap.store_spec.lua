require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

require "Common"
require "Promise"
require "bridge.BridgeCall"
require "bridge.BridgeResponse"

local PurchaseResponse = require("iap.response.PurchaseResponse")
local PurchaseRequest = require("iap.request.PurchaseRequest")
local Store = require("iap.Store")
local Ticket = require("iap.Ticket")
local Product = require("iap.Product")
local Transaction = require("iap.Transaction")

require("specs.helpers")
local match = require("specs.matchers")

describe("iap.Store", function()
    local subject
    local bridge
    local tickets
    local products
    local invalid

    before_each(function()
        bridge = require("bridge.modules.iap")
        tickets = {Ticket("id-1", "sku-1"), Ticket("id-2", "sku-2")}
        products = {Product("sku-1", "title-1", "description-1", "price-1"), Product("sku-2", "title-2", "description-2", "price-2")}
        invalid = {"sku-3", "sku-4"} 
        subject = Store(bridge, tickets, products, invalid)
    end)

    it("should return the products", function()
        assert.equal(products, subject.getProducts())
    end)

    it("should return the invalid SKUs", function()
        assert.equal(invalid, subject.getInvalidSKUs())
    end)

    it("should preturn product for respective product ID", function()
        assert.equal(products[1], subject.getProductWithId("id-1"))
        assert.equal(products[2], subject.getProductWithId("id-2"))
    end)

    describe("purchase product", function()
        local purchasep
        local purchasec
        local transaction
        local _error

        before_each(function()
            purchasec = BridgeCall()
            stub(bridge, "purchase", BridgeResponse(true, 20), purchasec)
            purchasep = subject.purchase(products[1])
            purchasep.done(function(_t)
                transaction = _t
            end)
            purchasep.fail(function(_e)
                _error = _e
            end)
        end)

        context("when the response is successful", function()
            before_each(function()
                purchasec.resolve(PurchaseResponse(20, "sku-1", "receipt-1"))
            end)

            it("should return SKU w/ receipt", function()
                assert.equal(Transaction, transaction.getClass())
                assert.equal("sku-1", transaction.getSKU())
                assert.equal("receipt-1", transaction.getReceipt())
            end)
        end)

        context("when the response fails", function()
            before_each(function()
                purchasec.reject(BridgeResponse(false, 20, "An error occurred"))
            end)

            it("should return error", function()
                assert.equal(Error, _error.getClass())
                assert.equal("An error occurred", _error.getMessage())
            end)
        end)
    end)

    describe("purchase product by ID", function()
        local promise
        local responsePromise

        before_each(function()
            promise = Promise()
            stub(subject, "purchase", promise)
            responsePromise = subject.purchaseProductWithId("id-2")
        end)

        it("should have made a call to purchase the product", function()
            assert.stub(subject.purchase).was.called_with(products[2])
        end)

        it("should have returned the purchase promise", function()
            assert.equal(promise, responsePromise)
        end)
    end)
end)
