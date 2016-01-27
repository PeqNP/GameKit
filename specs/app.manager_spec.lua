require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

local BridgeResponse = require("bridge.BridgeResponse")
local AppManager = require("app.Manager")
local AppNotificationResponse = require("app.response.AppNotificationResponse")
local AppSetupNotificationRequest = require("app.request.AppSetupNotificationRequest")

local match = require("luassert.match")

local function is_kind_of(state, arguments)
    local class = arguments[1]
    return function(value)
        if type(value) == "table" and value.getClass and value.getClass() == class then
            return true
        end
        return false
    end
end

assert:register("matcher", "is_kind_of", is_kind_of)

describe("AppManager", function()
    local subject
    local bridge

    before_each(function()
        bridge = require("bridge.modules.app")

        subject = AppManager(bridge)
    end)

    it("should set the delegate", function()
        local delegate = {}
        stub(bridge, "setDelegate")
        subject.setDelegate(delegate)
        assert.stub(bridge.setDelegate).was.called_with(delegate)
    end)

    describe("getting number of notifications", function()
        local response

        context("when successful", function()
            before_each(function()
                stub(bridge, "getNotifications", AppNotificationResponse(true, 44))
                response = subject.getNotifications()
            end)

            it("should have sent the request", function()
                assert.stub(bridge.getNotifications).was.called()
            end)

            it("should return correct value", function()
                assert.equal(44, response)
            end)
        end)

        context("when failure", function()
            before_each(function()
                stub(bridge, "getNotifications", AppNotificationResponse(false, nil, "Notification error"))
                response = subject.getNotifications()
            end)

            it("should return correct value", function()
                assert.equal(0, response)
            end)

            it("should have set the error", function()
                assert.equal("Notification error", subject.getError())
            end)
        end)
    end)

    describe("setting up notifications", function()
        local response

        context("when successful", function()
            before_each(function()
                stub(bridge, "setupNotification", BridgeResponse(true))
                response = subject.setupNotification("my message", 18)
            end)

            it("should have sent the request", function()
                assert.stub(bridge.setupNotification).was.called_with(match.is_kind_of(AppSetupNotificationRequest))
            end)

            it("should return true", function()
                assert.truthy(response)
            end)
        end)

        context("when failure", function()
            before_each(function()
                stub(bridge, "setupNotification", BridgeResponse(false, nil, "Setup failure"))
                response = subject.setupNotification("my message", 19)
            end)

            it("should return false", function()
                assert.falsy(response)
            end)

            it("should have set the error", function()
                assert.equal("Setup failure", subject.getError())
            end)
        end)
    end)
end)
