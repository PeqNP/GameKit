require "lang.Signal"
require "specs.Cocos2d-x"
require "json"
require "Logger"

Log.setLevel(LogLevel.Info)

local MediationAdConfig = require("mediation.AdConfig")

describe("MediationAdConfig", function()
    local subject

    local host
    local port
    local path

    describe("new", function()
        before_each(function()
            subject = MediationAdConfig(10, 20, 30, 40, 50, 60)
        end)

        it("should have set all values", function()
            assert.equals(10, subject.getAdNetwork())
            assert.equals(20, subject.getAdType())
            assert.equals(30, subject.getAdImpressionType())
            assert.equals(40, subject.getFrequency())
            assert.equals(50, subject.getRewardForImpression())
            assert.equals(60, subject.getRewardForClick())
        end)
    end)

    describe("fromDictionary", function()
        local dict
        before_each(function()
            dict = {adnetwork= 1, adtype= 2, adimpressiontype= 3, frequency= 4, impression= 5, click=6}
            subject = MediationAdConfig.fromDictionary(dict)
        end)

        it("should have set all values", function()
            assert.equals(1, subject.getAdNetwork())
            assert.equals(2, subject.getAdType())
            assert.equals(3, subject.getAdImpressionType())
            assert.equals(4, subject.getFrequency())
            assert.equals(5, subject.getRewardForImpression())
            assert.equals(6, subject.getRewardForClick())
        end)
    end)
end)
