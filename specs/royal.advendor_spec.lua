require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Warning)

local AdStylizer = require("royal.AdStylizer")
local AdConfig = require("royal.AdConfig")
local AdVendor = require("royal.AdVendor")
local AdUnit = require("royal.AdUnit")
local AdManifest = require("royal.AdManifest")
local ClickableAdUnit = require("royal.ClickableAdUnit")

describe("AdVendor", function()
    local subject
    local stylizer
    local adConfig

    local evolutions

    local adUnit1
    local adUnit2
    local adUnit3

    local fn__callback
    local wasCalled
    local adUnit

    -- Convenience method to print all memory addresses of ad units. Used for debugging
    -- only.
    local function print_ad_units(adUnit)
        print("adUnit1", adUnit1)
        print("adUnit2", adUnit2)
        print("adUnit3", adUnit3)
        print("Actual:", adUnit)
    end
    
    before_each(function()
        wasCalled = false
        fn__callback = function(_adUnit)
            wasCalled = true
            adUnit = _adUnit
        end

        local function fn__shouldShowTier(config)
            if not config then
                return false
            end
            for _, v in ipairs(evolutions) do
                if table.contains(config.evolutions, v) then
                    return true, v 
                end
            end
            return false
        end

        adUnit1 = AdUnit(100, 86400, 86500, "http://www.example.com/click1", 1000, "Title1", {evolutions={3,6,9}})
        -- NOTE: Ad units 2 and 3 have no config and, therefore, are always true.
        adUnit2 = AdUnit(200, 85000, 87000, "http://www.example.com/click2", 2000, "Title2")
        adUnit3 = AdUnit(300, 85000, 87000, "http://www.example.com/click3", 3000, "Title3")

        adConfig = AdConfig()
        stylizer = AdStylizer()
        subject = AdVendor(adConfig, stylizer, {adUnit1, adUnit2, adUnit3}, fn__shouldShowTier)
    end)

    pending("isActive")

    describe("when getting ad units", function()
        local ads

        context("when the evolution is in ad unit 1", function()
            before_each(function()
                evolutions = {6}
            end)

            describe("when all ad units are active", function()
                local ad

                before_each(function()
                    stub(adUnit1, "isActive", true)
                    stub(adUnit2, "isActive", true)
                    stub(adUnit3, "isActive", true)

                    ads = subject.getNextAdUnits(1, fn__callback)
                    ad = ads[1]
                end)

                it("should have returned a clickable ad unit", function()
                    assert.equal(ClickableAdUnit, ad.getClass())
                end)

                it("should return the second ad unit #f", function()
                    assert.equals(adUnit1.getId(), ads[1].getId())
                end)
            end)

            describe("when the first ad unit is inactive", function()
                before_each(function()
                    stub(adUnit1, "isActive", false)
                    stub(adUnit2, "isActive", true)
                    stub(adUnit3, "isActive", true)

                    ads = subject.getNextAdUnits(1, fn__callback)
                end)

                it("should return the second ad unit", function()
                    assert.equals(adUnit2.getId(), ads[1].getId())
                end)
            end)

            describe("when all ad units are inactive", function()
                before_each(function()
                    stub(adUnit1, "isActive", false)
                    stub(adUnit2, "isActive", false)
                    stub(adUnit3, "isActive", false)

                    ads = subject.getNextAdUnits(1, fn__callback)
                end)

                it("should return no ads", function()
                    assert.equals(0, #ads)
                end)
            end)
        end)

        context("when the evolutions are NOT in ad unit 1", function()
            before_each(function()
                evolutions = {7}
            end)

            describe("when all the ad units are active", function()
                before_each(function()
                    stub(adUnit1, "isActive", true)
                    stub(adUnit2, "isActive", true)
                    stub(adUnit3, "isActive", true)

                    ads = subject.getNextAdUnits(1, fn__callback)
                end)

                it("should return the second ad unit", function()
                    assert.equals(adUnit2.getId(), ads[1].getId())
                end)
            end)
        end)
    end)

    describe("when getting ads that are greater than the total number of ads", function()
        local ads

        before_each(function()
            evolutions = {3, 6, 9}

            stub(adUnit1, "isActive", true)
            stub(adUnit2, "isActive", true)
            stub(adUnit3, "isActive", true)
            ads = subject.getNextAdUnits(4)
        end)

        it("should only return the total number of ads", function()
            assert.equals(3, #ads)
        end)

        it("should have returned the correct ads", function()
            assert.equals(adUnit1.getId(), ads[1].getId())
            assert.equals(adUnit2.getId(), ads[2].getId())
            assert.equals(adUnit3.getId(), ads[3].getId())
        end)
    end)

    describe("when getting ad units sequentially", function()
        local ads

        before_each(function()
            evolutions = {3, 6, 9}

            stub(adUnit1, "isActive", true)
            stub(adUnit2, "isActive", true)
            stub(adUnit3, "isActive", true)

            ads = subject.getNextAdUnits(1)
        end)

        it("should have returned only one ad unit", function()
            assert.equals(1, #ads)
        end)

        it("should have returned the first ad", function()
            assert.equals(adUnit1.getId(), ads[1].getId())
        end)

        describe("call 2", function()
            before_each(function()
                ads = subject.getNextAdUnits(1)
            end)

            it("should have returned only one ad unit", function()
                assert.equals(1, #ads)
            end)

            it("should have returned the second ad", function()
                assert.equals(adUnit2.getId(), ads[1].getId())
            end)

            describe("call 3", function()
                before_each(function()
                    ads = subject.getNextAdUnits(1)
                end)

                it("should have returned only one ad unit", function()
                    assert.equals(1, #ads)
                end)

                it("should have returned the third ad", function()
                    assert.equals(adUnit3.getId(), ads[1].getId())
                end)

                describe("when querying for two additional ad units", function()
                    before_each(function()
                        ads = subject.getNextAdUnits(2)
                    end)

                    it("should have returned two ad units", function()
                        assert.equals(2, #ads)
                    end)

                    it("should have returned the first two ads", function()
                        assert.equals(adUnit1.getId(), ads[1].getId())
                        assert.equals(adUnit2.getId(), ads[2].getId())
                    end)

                    describe("call 4", function()
                        before_each(function()
                            ads = subject.getNextAdUnits(2)
                        end)

                        it("should have returned two ad units", function()
                            assert.equals(2, #ads)
                        end)

                        it("should have returned the last and first ad (round-robin)", function()
                            assert.equals(adUnit3.getId(), ads[1].getId())
                            assert.equals(adUnit1.getId(), ads[2].getId())
                        end)

                        describe("when the position is reset", function()
                            before_each(function()
                                subject.reset()
                                ads = subject.getNextAdUnits(1)
                            end)

                            it("should have returned the first button", function()
                                assert.equals(adUnit1.getId(), ads[1].getId())
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end)

    describe("get ad unit buttons", function()
        local buttons
        
        describe("when the evolution is 3", function()
            before_each(function()
                evolutions = {3}

                stub(adUnit1, "isActive", true)
                stub(adUnit2, "isActive", true)
                stub(adUnit3, "isActive", true)

                buttons = subject.getNextAdUnitButtons(1, fn__callback)
            end)

            it("should return one button", function()
                assert.equals(1, #buttons)
            end)

            it("should not have called callback", function()
                assert.falsy(wasCalled)
            end)

            describe("when the first button is tapped", function()
                before_each(function()
                    buttons[1]:activate()
                end)

                it("should have called the callback", function()
                    assert.truthy(wasCalled)
                end)

                it("should have returned the first ad unit", function()
                    assert.equals(adUnit1.getId(), adUnit.getId())
                end)
            end)
        end)

        describe("when the evolution is 7 (does not include ad unit 1)", function()
            before_each(function()
                evolutions = {7}

                stub(adUnit1, "isActive", true)
                stub(adUnit2, "isActive", true)
                stub(adUnit3, "isActive", true)

                buttons = subject.getNextAdUnitButtons(1, fn__callback)
            end)

            it("should return one button", function()
                assert.equals(1, #buttons)
            end)

            it("should not have called callback", function()
                assert.falsy(wasCalled)
            end)

            describe("when the button is tapped", function()
                before_each(function()
                    buttons[1]:activate()
                end)

                it("should have called the callback", function()
                    assert.truthy(wasCalled)
                end)

                it("should have returned the second ad unit", function()
                    assert.equals(adUnit2.getId(), adUnit.getId())
                end)
            end)
        end)
    end)
end)
