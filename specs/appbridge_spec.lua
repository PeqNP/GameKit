require "lang.Signal"
require "specs.busted"
require "Logger"

require "bridge.Bridge"

local match = require("luassert.match")

local function is_equal(state, arguments)
    local expected = arguments[1]
    return function(value)
        return table.equals(expected, value)
    end
end

assert:register("matcher", "equal", is_equal)

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