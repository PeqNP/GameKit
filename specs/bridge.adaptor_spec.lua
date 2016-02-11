require "lang.Signal"
require "Logger"
require "json"

Log.setLevel(LogLevel.Warning)

local BridgeAdaptor = require("bridge.BridgeAdaptor")

adaptor = {}
adaptor.callStaticMethod = function()
end

describe("BridgeAdaptor", function()
    local subject
    local args
    local called

    before_each(function()
        called = false
        local function paramFn(a)
            called = true
            return a
        end
        subject = BridgeAdaptor(adaptor, "Controller", paramFn)
    end)

    context("when the call succeeds", function()
        local response

        before_each(function()
            args = {}
            stub(adaptor, "callStaticMethod", true, nil)
            response = subject.send("method", args, "table") -- FIXME: There is no return type set.
        end)

        it("should return true", function()
            assert.truthy(response)
        end)

        it("should have made the call to the native layer", function()
            assert.stub(adaptor.callStaticMethod).was.called_with("Controller", "method", args, nil)
        end)

        it("should have called param function", function()
            assert.truthy(called)
        end)
    end)
end)

-- Sanity tests.
describe("Android JNI VM types", function()
    it("should convert all types of values into strings", function()
        local subject = json.encode({key=1})
        assert.equal("{\"key\":1}", subject)
        local subject = json.encode(1)
        assert.equal("1", subject)
        local subject = json.encode("Value")
        assert.equal("\"Value\"", subject)
        local subject = json.encode(true)
        assert.equal("true", subject)
    end)
end)
