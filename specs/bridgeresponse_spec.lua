require "lang.Signal"

require "bridge.BridgeResponse"

describe("AdRespose", function()
    local subject

    it("should be successful when success is 1", function()
        subject = BridgeResponse(1, nil)
        assert.truthy(subject.isSuccess())
    end)

    it("should be successful when success is true", function()
        subject = BridgeResponse(true, nil)
        assert.truthy(subject.isSuccess())
    end)

    it("should be failure when success is 0", function()
        subject = BridgeResponse(0, "error")
        assert.falsy(subject.isSuccess())
    end)

    it("should be failure when success is false", function()
        subject = BridgeResponse(false, "error")
        assert.falsy(subject.isSuccess())
    end)
end)
