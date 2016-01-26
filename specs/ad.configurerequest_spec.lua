require "lang.Signal"

require "ad.Constants"
local AdConfig = require("ad.Config")
local AdConfigureRequest = require("ad.request.AdConfigureRequest")

describe("AdConfigureRequest", function()
    local subject

    before_each(function()
        subject = AdConfigureRequest(AdConfig({"device-1", "device-2"}, true, AdOrientation.AutoDetect))
    end)

    it("should produce the correct dictionary", function()
        assert.truthy(table.equals({testDevices="device-1,device-2", automatic=true, orientation=AdOrientation.AutoDetect}, subject.toDict()))
    end)
end)
