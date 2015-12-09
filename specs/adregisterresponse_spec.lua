require "lang.Signal"

require "ad.response.AdRegisterResponse"

describe("AdRespose", function()
    local subject
    local strTokens
    local tokens

    before_each(function()
        strTokens = "token1,token2"
        tokens = {"token1", "token2"}
    end)

    it("should be successful when success is 1", function()
        subject = AdRegisterResponse(1, strTokens, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)

    it("should be successful when success is true", function()
        subject = AdRegisterResponse(true, strTokens, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)

    it("should be failure when success is 0", function()
        subject = AdRegisterResponse(0, strTokens, "error")
        assert.falsy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)

    it("should be failure when success is false", function()
        subject = AdRegisterResponse(false, strTokens, "error")
        assert.falsy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)
end)
