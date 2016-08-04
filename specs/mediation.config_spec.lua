require "lang.Signal"
LuaFile = require("LuaFile")

local MediationConfig = require("mediation.Config")

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

describe("MediationConfig", function()
    local subject

    describe("fromJson", function()
        local file = LuaFile()
        local blob = file.read("specs/mediation.json")
        assert.truthy(blob)
        subject = MediationConfig.fromJson(blob)
    end)

    it("should have created a Config", function()
        assert.truthy(MediationConfig, subject.getClass())
    end)

    it("should have inflated two ads", function()
        local ads = subject.getAds()
        assert.equal(2, #ads)
    end)

    it("should have inflated the ads correctly", function()
        local ads = subject.getAds()
        local ad = ads[1]
        assert.equal(2, ad.getAdNetwork())
        assert.equal(2, ad.getAdType())
        assert.equal(1, ad.getAdImpressionType())
        assert.equal(80, ad.getFrequency())
        assert.equal(5, ad.getRewardForImpression())
        assert.equal(25, ad.getRewardForClick())
    end)
end)
