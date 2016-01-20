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
local RestorePurchaseResponse = require("iap.response.RestorePurchaseResponse")
local PurchaseResponse = require("iap.response.PurchaseResponse")
local PurchaseRequest = require("iap.request.PurchaseRequest")
local Manager = require("iap.Manager")
local Ticket = require("iap.Ticket")
local Product = require("iap.Product")
local Store = require("iap.Store")
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

    describe("query products", function()
        local response
        local promise
        local store
        local invalidSKUs
        local errorResponse
        local tickets

        before_each(function()
            response = BridgeCall()
            stub(bridge, "query", BridgeResponse(true, 10), response)
            tickets = {Ticket("id-1", "sku-1"), Ticket("id-2", "sku-2"), Ticket("id-3", "sku-3"), Ticket("id-4", "sku-4")}

            promise = subject.fetchProducts(tickets)
            promise.done(function(_store, _invalid)
                store = _store
                invalidSKUs = _invalid
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

            it("should have returned a fully functional Store", function()
                assert.equal(Store, store.getClass())
                assert.equal(bridge, store.getBridge())
            end)

            it("should have set the products on the store", function()
                local products = store.getProducts()
                assert.equal(2, #products)
                assert.equal(Product, products[1].getClass()) -- sanity
            end)

            it("should have set the invalid SKUs on the store", function()
                assert.truthy(table.equals({"sku-3", "sku-4"}, invalidSKUs))
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
    end)
end)

