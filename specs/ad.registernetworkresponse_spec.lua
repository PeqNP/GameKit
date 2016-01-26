require "lang.Signal"

local AdRegisterNetworkResponse = require("ad.response.AdRegisterNetworkResponse")

describe("AdRegisterNetworkResponse", function()
    local subject
    local strAppIds
    local appIds

    before_each(function()
        strAppIds = "1,2"
        appIds = {1, 2}
    end)

    it("should be successful when success is 1", function()
        subject = AdRegisterNetworkResponse(1, strAppIds, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(table.equals(appIds, subject.getAdIds()))
    end)

    it("should be successful when success is true", function()
        subject = AdRegisterNetworkResponse(true, strAppIds, nil)
        assert.truthy(subject.isSuccess())
        assert.truthy(table.equals(appIds, subject.getAdIds()))
    end)

    it("should be failure when success is 0", function()
        subject = AdRegisterNetworkResponse(0, strAppIds, "error")
        assert.falsy(subject.isSuccess())
        assert.truthy(table.equals(appIds, subject.getAdIds()))
    end)

    it("should be failure when success is false", function()
        subject = AdRegisterNetworkResponse(false, strAppIds, "error")
        assert.falsy(subject.isSuccess())
        assert.truthy(table.equals(appIds, subject.getAdIds()))
    end)
end)
