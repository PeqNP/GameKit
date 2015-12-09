require "lang.Signal"

require "ad.response.AdRegisterNetworkResponse"

describe("AdRegisterNetworkResponse", function()
    local subject
    local strTokens
    local tokens

    before_each(function()
        strTokens = "1,2"
        tokens = {1, 2}
    end)

    it("should be successful when success is 1", function()
        subject = AdRegisterNetworkResponse(1, strTokens, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)

    it("should be successful when success is true", function()
        subject = AdRegisterNetworkResponse(true, strTokens, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)

    it("should be failure when success is 0", function()
        subject = AdRegisterNetworkResponse(0, strTokens, "error")
        assert.falsy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)

    it("should be failure when success is false", function()
        subject = AdRegisterNetworkResponse(false, strTokens, "error")
        assert.falsy(subject.isSuccess())
        assert.truthy(table.equals(tokens, subject.getTokens()))
    end)
end)
