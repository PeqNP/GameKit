require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Warning)

local shim = require("shim.System")
local AdConfig = require("royal.AdConfig")
local AdUnit = require("royal.AdUnit")
local ClickableAdUnit = require("royal.ClickableAdUnit")

describe("ClickableAdUnit", function()
    local subject
    local adUnit
    local adConfig

    before_each(function()
        stub(shim, "GetTime", 86700)
        stub(shim, "OpenURL")

        adConfig = AdConfig()
        stub(adConfig, "write")
    end)

    context("when the ad unit has a key", function()
        local config

        before_each(function()
            config = {evolutions={3,6,9}}
            adUnit = AdUnit(100, 86400, 86500, "http://www.example.com/click1", 1000, "Title1", config)
            subject = ClickableAdUnit(adConfig, adUnit, 6)
        end)

        it("should have passed all of the properties to subclass", function()
            assert.equal(100, subject.getId())
            assert.equal(86400, subject.getStartDate())
            assert.equal(86500, subject.getEndDate())
            assert.equal("http://www.example.com/click1", subject.getURL())
            assert.equal(1000, subject.getReward())
            assert.equal("Title1", subject.getTitle())
            assert.truthy(config, subject.getConfig())
        end)

        context("when the ad is clicked", function()
            before_each(function()
                subject.click()
            end)

            it("should have saved the current time to a file", function()
                assert.stub(adConfig.write).was.called_with("id100-key6-click.json", "86700")
            end)

            it("should have opened the URL", function()
                assert.stub(shim.OpenURL).was.called_with("http://www.example.com/click1")
            end)
        end)
    end)

    context("when the ad unit DOES NOT has a key", function()
        before_each(function()
            adUnit = AdUnit(200, 86400, 86500, "http://www.example.com/click2", 1000, "Title1")
            subject = ClickableAdUnit(adConfig, adUnit)
            subject.click()
        end)

        it("should have saved the current time to a file", function()
            assert.stub(adConfig.write).was.called_with("id200-click.json", "86700")
        end)

        it("should have opened the URL", function()
            assert.stub(shim.OpenURL).was.called_with("http://www.example.com/click2")
        end)
    end)
end)
