require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

local AdConfig = require("royal.AdConfig")

describe("singleton", function()
    it("should have created a singleton", function()
        assert.truthy(AdConfig.singleton)
        assert.truthy(AdConfig.singleton.kindOf(AdConfig))
    end)
end)

describe("AdConfig", function()
    local subject

    before_each(function()
        subject = AdConfig()
    end)

    it("should not have a base path", function()
        assert.falsy(subject.getBasePath())
    end)

    it("should return default image variant 'sd'", function()
        assert.equal("sd", subject.getImageVariant())
    end)

    describe("setBasePath", function()
        before_each(function()
            subject.setBasePath("/path/")
        end)

        it("should have set the base path", function()
            assert.equal("/path/", subject.getBasePath())
        end)
    end)

    describe("setImageVariant", function()
        before_each(function()
            subject.setImageVariant("/path/")
        end)

        it("should have set the base path", function()
            assert.equal("/path/", subject.getImageVariant())
        end)
    end)
end)
