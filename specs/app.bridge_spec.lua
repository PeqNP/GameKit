require "lang.Signal"
require "specs.busted"
require "Logger"

local Bridge = require("bridge.Bridge")
local AppNotificationResponse = require("app.response.AppNotificationResponse")

local match = require("specs.matchers")

describe("modules.app", function()
    local subject
    local bridge
    local call
    local request
    local response

    before_each(function()
        request = {}
        response = {}

        bridge = Bridge()

        subject = require("bridge.modules.app")
        subject.init(bridge)
    end)

    describe("getting notifications", function()
        local response

        before_each(function()
            stub(bridge, "send", {success=true, notifications=23})
            response = subject.getNotifications()
        end)

        it("should have made call to bridge", function()
            assert.stub(bridge.send).was.called_with("app__getNotifications")
        end)

        it("should return a BridgeResponse", function()
            assert.equal(AppNotificationResponse, response.getClass())
            assert.equal(23, response.getNotifications())
        end)
    end)
end)
