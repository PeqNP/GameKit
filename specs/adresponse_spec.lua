require "lang.Signal"

require "ad.response.AdResponse"

describe("AdRespose", function()
    local subject

    it("should be successful when success is 1", function()
        subject = AdResponse(1, nil)
        assert.truthy(subject.isSuccess())
    end)

    it("should be successful when success is true", function()
        subject = AdResponse(true, nil)
        assert.truthy(subject.isSuccess())
    end)

    it("should be failure when success is 0", function()
        subject = AdResponse(0, "error")
        assert.falsy(subject.isSuccess())
    end)

    it("should be failure when success is false", function()
        subject = AdResponse(false, "error")
        assert.falsy(subject.isSuccess())
    end)
end)
