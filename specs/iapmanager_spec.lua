require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

require "Common"
require "bridge.BridgeCall"
require "bridge.BridgeResponse"

local match = require("specs.matchers")
matchers_assert(assert)

local QueryRequest = require("iap.request.QueryRequest")
local QueryResponse = require("iap.response.QueryResponse")
local TransactionResponse = require("iap.response.TransactionResponse")
local TransactionFailedResponse = require("iap.response.TransactionFailedResponse")
local TransactionRequest = require("iap.request.TransactionRequest")
local IAPManager = require("iap.Manager")
local IAPProduct = require("iap.Product")

require("specs.helpers")
local match = require("specs.matchers")

describe("IAPManager", function()
    local subject
    local bridge

    before_each(function()
        bridge = require("bridge.modules.iap")
        subject = IAPManager(bridge)
    end)

    describe("query SKUs", function()
        local response
        local promise
        local blockProducts
        local blockInvalid
        local errorResponse

        before_each(function()
            response = BridgeCall()
            stub(bridge, "query", BridgeResponse(true, 10), response)

            promise = subject.querySKUs({"sku-1", "sku-2", "sku-3, sku-4"})
            promise.done(function(_products, _invalid)
                blockProducts = _products
                blockInvalid = _invalid
            end)
            promise.fail(function(_r)
                errorResponse = _r
            end)
        end)

        it("should have made call to bridge", function()
            assert.stub(bridge.query).was.called_with(match.is_kind_of(QueryRequest))
        end)

        context("when the response is successful", function()
            local nativeResponse

            before_each(function()
                nativeResponse = QueryResponse(10, "sku-1:title-1:description-1:price-1,sku-2:title-2:description-2:price-2", "sku-3,sku-4")
                response.resolve(nativeResponse)
            end)

            it("should return products", function()
                assert.equal(2, #blockProducts)
                assert.equal(IAPProduct, blockProducts[1].getClass())
            end)

            it("should return array of invalid SKUs", function()
                assert.truthy(table.equals({"sku-3", "sku-4"}, blockInvalid))
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
        end)
    end)

    describe("purchase SKU", function()
        local promise
        local transaction
        local _error

        before_each(function()
            response = BridgeCall()
            stub(bridge, "purchase", BridgeResponse(true, 20), response)
            promise = subject.purchaseSKU("sku-1")
            promise.done(function(_t)
                transaction = _t
            end)
            promise.fail(function(_e)
                _error = _e
            end)
        end)

        it("should have made call to bridge", function()
            assert.stub(bridge.purchase).was.called_with(match.is_kind_of(TransactionRequest))
        end)

        context("when the response is successful", function()
            before_each(function()
                promise.resolve(TransactionResponse(20, "sku-1", "receipt-1"))
            end)

            it("should return SKU w/ receipt", function()
                assert.equal(Transaction, transaction.getClass())
                assert.equal("sku-1", transaction.getSKU())
                assert.equal("receipt-1", transaction.getReceipt())
            end)
        end)

        context("when the response fails", function()
            before_each(function()
                promise.reject(TransactionFailedResponse(20, "An error occurred"))
            end)

            it("should return error", function()
                assert.equal(Error, _error.getClass())
                assert.equal("An error occurred", _error.getMessage())
            end)
        end)
    end)

    describe("restore purchases", function()
        before_each(function()
            response = BridgeCall()
            stub(bridge, "restore", BridgeResponse(true, 30), response)
            subject.restorePurchases()
        end)

        context("when the response is successful", function()
            before_each(function()
            end)

            it("should return purchased SKUs", function()
            end)
        end)

        context("when the response fails", function()
            before_each(function()
            end)

            it("should return error", function()
            end)
        end)
    end)
end)

