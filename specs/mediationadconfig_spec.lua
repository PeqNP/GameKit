
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
            assert.equals(10, subject.adnetwork)
            assert.equals(20, subject.adtype)
            assert.equals(30, subject.adimpressiontype)
            assert.equals(40, subject.frequency)
            assert.equals(50, subject.reward)
        end)
    end)

    describe("fromDictionary", function()
        local dict
        before_each(function()
            dict = {adnetwork= 1, adtype= 2, adimpressiontype= 3, frequency= 4, reward= 5}
            subject = MediationAdConfig.fromDictionary(dict)
        end)

        it("should have set all values", function()
            assert.equals(1, subject.adnetwork)
            assert.equals(2, subject.adtype)
            assert.equals(3, subject.adimpressiontype)
            assert.equals(4, subject.frequency)
            assert.equals(5, subject.reward)
        end)
    end)
end)
