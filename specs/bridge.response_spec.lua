require "lang.Signal"

local BridgeResponse = require("bridge.BridgeResponse")

describe("AdRespose", function()
    local subject

    it("should be successful when success is 1", function()
        subject = BridgeResponse(1, 10, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(10, subject.getId())
    end)

    it("should be successful when success is true", function()
        subject = BridgeResponse(true, 20, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(20, subject.getId())
    end)

    it("should be failure when success is 0", function()
        subject = BridgeResponse(0, nil, "error")
        assert.falsy(subject.isSuccess())
        assert.falsy(subject.getId())
        assert.equal("error", subject.getError())
    end)

    it("should be failure when success is false", function()
        subject = BridgeResponse(false, nil, "error")
        assert.falsy(subject.isSuccess())
        assert.falsy(subject.getId())
        assert.equal("error", subject.getError())
    end)
end)
