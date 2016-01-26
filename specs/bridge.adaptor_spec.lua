require "lang.Signal"
require "Logger"

Log.setLevel(LogLevel.Warning)

require "bridge.BridgeAdaptor"

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
            response = subject.send("method", args, "sig")
        end)

        it("should return true", function()
            assert.truthy(response)
        end)

        it("should have made the call to the native layer", function()
            assert.stub(adaptor.callStaticMethod).was.called_with("Controller", "method", args, "sig")
        end)

        it("should have called param function", function()
            assert.truthy(called)
        end)
    end)
end)
