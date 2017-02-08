require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

local LuaFile = require("LuaFile")
local AdConfig = require("royal.AdConfig")

describe("AdConfig", function()
    local subject

    before_each(function()
        subject = AdConfig("/path/")
    end)

    it("should return the base path", function()
        assert.equal("/path/", subject.getBasePath())
    end)

    it("should return default image variant 'sd'", function()
        assert.equal("sd", subject.getImageVariant())
    end)

    it("should return the correct image path", function()
        assert.equals("/path/royal.png", subject.getImageFilepath())
    end)

    it("should return the correct plist path", function()
        assert.equals("/path/royal.plist", subject.getPlistFilepath())
    end)

    it("should return the correct config path", function()
        assert.equals("/path/royal.json", subject.getConfigFilepath())
    end)

    describe("setImageVariant", function()
        before_each(function()
            subject.setImageVariant("hd")
        end)

        it("should have set the variant", function()
            assert.equal("hd", subject.getImageVariant())
        end)
    end)

    pending("write")

    pending("read")
end)
