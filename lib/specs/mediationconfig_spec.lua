
require "lang.Signal"

require "mediation.MediationConfig"

describe("MediationConfig", function()
    local subject

    describe("new", function()
        local ads

        before_each(function()
            ads = {}
            subject = MediationConfig(10, ads)
        end)

        it("should have set the properties", function()
            assert.equals(10, subject.getVersion())
            assert.equals(ads, subject.getAds())
        end)
    end)
end)
