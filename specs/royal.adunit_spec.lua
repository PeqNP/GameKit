require "lang.Signal"
require "specs.Cocos2d-x"

local AdUnit = require("royal.AdUnit")

describe("AdUnit", function()
    local subject
    local config

    before_each(function()
        config = {}
        subject = AdUnit(1, 86400, 86500, "http://www.example.com", 20, "Title", config)
    end)

    it("should have set all values", function()
        assert.equals(1, subject.getId())
        assert.equals(86400, subject.getStartDate())
        assert.equals(88500, subject.getEndDate())
        assert.equals("http://www.example.com", subject.getURL())
        assert.equals(20, subject.getReward())
        assert.equals("Title", subject.getTitle())
        assert.equals(config, subject.getConfig())
    end)

    describe("when the ad just started", function()
        before_each(function()
            stub(socket, "gettime", 86400)
        end)

        it("should be active", function()
            assert.truthy(subject.isActive())
        end)
    end)

    describe("when the ad is running", function()
        before_each(function()
            stub(socket, "gettime", 86450)
        end)

        it("should be active", function()
            assert.truthy(subject.isActive())
        end)
    end)

    describe("when the ad is about to end", function()
        before_each(function()
            stub(socket, "gettime", 86500)
        end)

        it("should be active", function()
            assert.truthy(subject.isActive())
        end)
    end)

    describe("when the ad unit hasn't started", function()
        before_each(function()
            stub(socket, "gettime", 86399)
        end)

        it("should not be active", function()
            assert.falsy(subject.isActive())
        end)
    end)

    describe("when the ad unit has expired", function()
        before_each(function()
            stub(socket, "gettime", 86501)
        end)

        it("should not be active", function()
            assert.falsy(subject.isActive())
        end)
    end)
end)
