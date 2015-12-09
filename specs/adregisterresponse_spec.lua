require "lang.Signal"

require "ad.response.AdRegisterResponse"

describe("AdRespose", function()
    local subject
    local tokens

    before_each(function()
        tokens = {}
    end)

    it("should be successful when success is 1", function()
        subject = AdRegisterResponse(1, tokens, nil)
        assert.truthy(subject.isSuccess())
        assert.equal(tokens, subject.getTokens())
    end)

    it("should be successful when success is true", function()
        subject = AdRegisterResponse(true, tokens, nil)
        assert.truthy(subject.isSuccess())
        assert.equal(tokens, subject.getTokens())
    end)

    it("should be failure when success is 0", function()
        subject = AdRegisterResponse(0, tokens, "error")
        assert.falsy(subject.isSuccess())
        assert.equal(tokens, subject.getTokens())
    end)

    it("should be failure when success is false", function()
        subject = AdRegisterResponse(false, tokens, "error")
        assert.falsy(subject.isSuccess())
        assert.equal(tokens, subject.getTokens())
    end)
end)
