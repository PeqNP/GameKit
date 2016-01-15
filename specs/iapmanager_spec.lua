require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

require "Common"
require "bridge.BridgeCall"
require "bridge.BridgeResponse"

local TransactionCompletedResponse = require("iap.response.TransactionCompletedResponse")
local TransactionFailedResponse = require("iap.response.TransactionFailedResponse")
local TransactionRequest = require("iap.request.TransactionRequest")
local IAPManager = require("iap.IAPManager")

require("specs.helpers")
local match = require("specs.matchers")

describe("IAPManager", function()
    local subject
    local bridge

    before_each(function()
        bridge = require("bridge.modules.iap")
        subject = IAPManager(bridge)
    end)

    describe("registering SKUs", function()
        local response
        local promise
        local blockResponse
        local errorResponse

        before_each(function()
            response = BridgeCall()
            stub(bridge, "query", BridgeResponse(true, 10), response)

            promise = subject.querySKUs({"sku-1", "sku-2", "sku-3"})
            promise.done(function(_r)
                blockResponse = _r
            end)
            promise.fail(function(_r)
                errorResponse = _r
            end)
        end)

        it("should have made call to bridge", function()
            assert.stub(bridge.query).was.called_with(match.is_kind_of(TransactionQueryRequest))
        end)

        context("when the response is successful", function()
            local nativeResponse

            before_each(function()
                nativeResponse = {}
                response.resolve(nativeResponse)
            end)

            it("should have returned the response", function()
                assert.equal(nativeResponse, blockResponse)
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
        before_each(function()
            response = BridgeCall()
            stub(bridge, "purchase", BridgeResponse(true, 20), response)
            subject.purchaseSKU("sku-1")
        end)

        context("when the response is successful", function()
            before_each(function()
            end)

            it("should return SKU w/ receipt", function()
            end)
        end)

        context("when the response fails", function()
            before_each(function()
            end)

            it("should return error", function()
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

