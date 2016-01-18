require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

require "Common"
require "bridge.BridgeCall"
require "bridge.BridgeResponse"

local match = require("specs.matchers")
matchers_assert(assert)

require "bridge.BridgeResponse"

local QueryRequest = require("iap.request.QueryRequest")
local QueryResponse = require("iap.response.QueryResponse")
local RestorePurchaseResponse = require("iap.response.RestorePurchaseResponse")
local PurchaseResponse = require("iap.response.PurchaseResponse")
local PurchaseRequest = require("iap.request.PurchaseRequest")
local Manager = require("iap.Manager")
local Product = require("iap.Product")
local Transaction = require("iap.Transaction")

require("specs.helpers")
local match = require("specs.matchers")

describe("iap.Manager", function()
    local subject
    local bridge

    before_each(function()
        bridge = require("bridge.modules.iap")
        subject = Manager(bridge)
    end)

    it("should return false when there are no SKUs that can be purchased", function()
        assert.falsy(subject.hasProducts())
    end)

    describe("query products", function()
        local response
        local promise
        local products
        local blockInvalid
        local errorResponse

        before_each(function()
            response = BridgeCall()
            stub(bridge, "query", BridgeResponse(true, 10), response)

            promise = subject.queryProducts({"sku-1", "sku-2", "sku-3, sku-4"})
            promise.done(function(_products, _invalid)
                products = _products
                blockInvalid = _invalid
            end)
            promise.fail(function(_r)
                errorResponse = _r
            end)
        end)

        context("when the response is successful", function()
            local nativeResponse

            before_each(function()
                nativeResponse = QueryResponse(10, "sku-1:title-1:description-1:price-1,sku-2:title-2:description-2:price-2", "sku-3,sku-4")
                response.resolve(nativeResponse)
            end)

            it("should return products", function()
                assert.equal(2, #products)
                assert.equal(Product, products[1].getClass())
            end)

            it("should return array of invalid SKUs", function()
                assert.truthy(table.equals({"sku-3", "sku-4"}, blockInvalid))
            end)

            it("should have products to purchase", function()
                assert.truthy(subject.hasProducts())
            end)

            describe("purchase SKU", function()
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
        end)

        context("when the response fails", function()
            local nativeResponse

            before_each(function()
                nativeResponse = {}
                response.reject(nativeResponse)
            end)

            it("should return error", function()
                assert.equal(nativeResponse, errorResponse)
            end)

            it("should NOT have products to purchase", function()
                assert.falsy(subject.hasProducts())
            end)
        end)
    end)

    describe("restore purchases", function()
        local promise
        local transactions
        local _error

        before_each(function()
            call = BridgeCall()
            stub(bridge, "restore", BridgeResponse(true, 30), call)
            promise = subject.restorePurchases()
            promise.done(function(_t)
                transactions = _t
            end)
            promise.fail(function(_e)
                _error = _e
            end)
        end)

        context("when the response is successful", function()
            before_each(function()
                call.resolve(RestorePurchaseResponse(30, "sku-1:receipt-1,sku-2:receipt-2"))
            end)

            it("should return purchased SKUs", function()
                assert.equal(2, #transactions)
                assert.equal("sku-1", transactions[1].getSKU())
                assert.equal("receipt-1", transactions[1].getReceipt())
            end)
        end)

        context("when the response fails", function()
            before_each(function()
                call.reject(BridgeResponse(false, 30, "An error occurred"))
            end)

            it("should return error", function()
                assert.equal("An error occurred", _error.getMessage())
            end)
        end)

        it("should NOT have SKUs to purchase", function()
            assert.falsy(subject.hasProducts())
        end)
    end)
end)

