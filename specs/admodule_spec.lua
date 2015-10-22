require "lang.Signal"

require "ad.modules.AdMobInterstitial"

describe("AdModule", function()
    local subject

    before_each(function()
        subject = AdMobInterstitial()
    end)

    describe("devices", function()
        local devices

        before_each(function()
            devices = {}
            subject.setDevices(devices)
        end)

        it("should return our devices", function()
            assert.equal(devices, subject.getDevices())
        end)
    end)

end)
