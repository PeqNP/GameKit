require "lang.Signal"
require "Logger"
require "json"

Log.setLevel(LogLevel.Error)

local BridgeAdaptor = require("bridge.adaptor.AppleAdaptor")

adaptor = {}
adaptor.callStaticMethod = function() end

describe("BridgeAdaptor", function()
    local subject
    local args

    before_each(function()
        subject = BridgeAdaptor(adaptor, "Controller")
    end)

    context("when the call succeeds", function()
        local response

        before_each(function()
            args = {}
            stub(adaptor, "callStaticMethod", true, "string value")
            response = subject.send("method", args, "table") -- FIXME: There is no return type set.
        end)

        it("should have made the call to the native layer", function()
            assert.stub(adaptor.callStaticMethod).was.called_with("Controller", "method", args)
        end)

        it("should return the Lua value returned from native land", function()
            assert.equal("string value", response)
        end)
    end)

    context("when the call fails", function()
        local response

        before_each(function()
            args = {}
            stub(adaptor, "callStaticMethod", -1, nil)
            response = subject.send("method", args, "table") -- FIXME: There is no return type set.
        end)

        it("should have made the call to the native layer", function()
            assert.stub(adaptor.callStaticMethod).was.called_with("Controller", "method", args)
        end)

        it("should return nil", function()
            assert.falsy(response)
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
