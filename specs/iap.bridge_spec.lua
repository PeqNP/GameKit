require "lang.Signal"
require "specs.busted"
require "Logger"

Log.setLevel(LogLevel.Warning)

require "bridge.modules.iap"
local Bridge = require("bridge.Bridge")
local BridgeCall = require("bridge.BridgeCall")
local BridgeResponse = require("bridge.BridgeResponse")
local PurchaseRequest = require("iap.request.PurchaseRequest")
local PurchaseResponse = require("iap.response.PurchaseResponse")
local RestorePurchaseResponse = require("iap.response.RestorePurchaseResponse")

describe("modules.iap", function()
    local subject
    local bridge

    before_each(function()
        request = {}
        response = {}

        bridge = Bridge()
        mock(bridge, true)
        call = BridgeCall()
        mock(call, true)

        subject = require("bridge.modules.iap")
        subject.init(bridge)
    end)

    describe("purchase", function()
        local request
        local response

        before_each(function()
            request = PurchaseRequest("product-id")
        end)

        context("when the process succeeds", function()
            before_each(function()
                stub(bridge, "sendAsync", {success=true, id=20})
                response = subject.purchase(request)
            end)

            it("should have made call to the bridge", function()
                assert.stub(bridge.sendAsync).was.called_with("iap__purchase", request)
            end)

            it("should have created the correct response", function()
                assert.equal(BridgeResponse, response.getClass())
                assert.truthy(response.isSuccess())
            end)
        end)

        context("when the process fails", function()
            before_each(function()
                stub(bridge, "sendAsync", {success=false, error="purchase failure"})
                response = subject.purchase(request)
            end)

            it("should have made call to the bridge", function()
                assert.stub(bridge.sendAsync).was.called_with("iap__purchase", request)
            end)

            it("should have created the correct response", function()
                assert.equal(BridgeResponse, response.getClass())
                assert.falsy(response.isSuccess())
                assert.equal("purchase failure", response.getError())
            end)
        end)
    end)

    describe("restore", function()
        local response

        context("when the process succeeds", function()
            before_each(function()
                stub(bridge, "sendAsync", {success=true, id=20})
                response = subject.restore()
            end)

            it("should have made call to the bridge", function()
                assert.stub(bridge.sendAsync).was.called_with("iap__restore")
            end)

            it("should have created the correct response", function()
                assert.equal(BridgeResponse, response.getClass())
                assert.truthy(response.isSuccess())
            end)
        end)

        context("when the process fails", function()
            before_each(function()
                stub(bridge, "sendAsync", {success=false, error="restore failure"})
                response = subject.restore()
            end)

            it("should have made call to the bridge", function()
                assert.stub(bridge.sendAsync).was.called_with("iap__restore")
            end)

            it("should have created the correct response", function()
                assert.equal(BridgeResponse, response.getClass())
                assert.falsy(response.isSuccess())
                assert.equal("restore failure", response.getError())
            end)
        end)
    end)
end)

describe("IAP Receive", function()
    local subject
    local bridge
    local response

    before_each(function()
        response = nil

        bridge = Bridge()
        bridge.receive = function(r)
            response = r
        end

        subject = require("bridge.modules.iap")
        subject.init(bridge)
    end)

    describe("complete a purchase", function()
        local json

        before_each(function()
            json = "{\"id\": 30, \"sku\": \"sku-1\", \"receipt\": \"012345689\"}"
            iap__purchased(json)
        end)

        it("should have sent message to bridge that a transaction was completed", function()
            assert.truthy(response)
            assert.equal(PurchaseResponse, response.getClass())
        end)

        it("should have set the correct values", function()
            assert.equal(30, response.getId())
            assert.equal("sku-1", response.getSKU())
            assert.equal("012345689", response.getReceipt())
        end)
    end)

    describe("restore a transaction", function()
        local json 

        before_each(function()
            json = "{\"id\": 40, \"skus\": \"sku-2:1234567890\"}"
            iap__restored(json)
        end)

        it("should have sent message to bridge that a transaction was restored", function()
            assert.truthy(response)
            assert.equal(RestorePurchaseResponse, response.getClass())
        end)

        it("should have set the correct values", function()
            local transactions = response.getTransactions()
            assert.equal(1, #transactions)
            assert.equal(40, response.getId())

            local transaction = transactions[1]
            assert.equal("sku-2", transaction.getSKU())
            assert.equal("1234567890", transaction.getReceipt())
        end)
    end)

    describe("failed transaction", function()
        local json

        before_each(function()
            json = "{\"id\": 50, \"error\": \"an error :(\"}"
            iap__failed(json)
        end)

        it("should have sent message to bridge that a transaction was restored", function()
            assert.truthy(response)
            assert.equal(BridgeResponse, response.getClass())
        end)

        it("should have set the correct values", function()
            assert.falsy(response.isSuccess())
            assert.equal(50, response.getId())
            assert.equal("an error :(", response.getError())
        end)
    end)
end)
