
require "lang.Signal"
require "specs.Cocos2d-x"
require "json"
require "Logger"

Log.setLevel(LogLevel.Info)

require "mediation.MediationAdConfig"

describe("MediationAdConfig", function()
    local subject

    local host
    local port
    local path

    describe("new", function()
        before_each(function()
            subject = MediationAdConfig(10, 20, 30, 40, 50)
        end)

        it("should have set all values", function()
            assert.equals(10, subject.getAdNetwork())
            assert.equals(20, subject.getAdType())
            assert.equals(30, subject.getAdImpressionType())
            assert.equals(40, subject.getFrequency())
            assert.equals(50, subject.getReward())
        end)
    end)

    describe("fromDictionary", function()
        local dict
        before_each(function()
            dict = {adnetwork= 1, adtype= 2, adimpressiontype= 3, frequency= 4, reward= 5}
            subject = MediationAdConfig.fromDictionary(dict)
        end)

        it("should have set all values", function()
            assert.equals(1, subject.getAdNetwork())
            assert.equals(2, subject.getAdType())
            assert.equals(3, subject.getAdImpressionType())
            assert.equals(4, subject.getFrequency())
            assert.equals(5, subject.getReward())
        end)
    end)
end)
