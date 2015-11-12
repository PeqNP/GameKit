require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"
require "Common"

Log.setLevel(LogLevel.Info)

require "royal.AdConfig"
require "royal.AdPresenter"
require "royal.AdTier"
require "royal.AdUnit"
require "royal.AdManifest"

AdConfig.singleton.setBasePath("/path/")

describe("AdPresenter", function()
    local subject = false

    local evolutions

    local adUnit1
    local adUnit2
    local adUnit3
    local tier1
    local tier2
    local tier3
    local tier4
    local tier5

    local fn__callback
    local wasCalled
    local tier
    
    before_each(function()
        -- Prevent AdTier from loading clicks from disk.
        stub(io, "open")
        stub(io, "input")
        stub(io, "output")
        stub(io, "read")
        stub(io, "write")
        stub(io, "close")

        evolutions = {}

        wasCalled = false
        tier = false
        fn__callback = function(t)
            wasCalled = true
            tier = t
        end

        local function fn__shouldShowTier(config)
            if not config then
                return false
            end
            for _, v in ipairs(evolutions) do
                if v == config.evolution then
                    return true
                end
            end
            return false
        end

        tier1 = AdTier(1000, "http://www.example.com/tier/1000", 20, "Click 1", 86400, 1, {evolution = 3})
        tier2 = AdTier(1001, "http://www.example.com/tier/1001", 50, "Click 2", 86400, 2, {evolution = 6})
        tier3 = AdTier(1002, "http://www.example.com/tier/1002", 70, "Click 3", 86400, 1, {evolution = 9})
        adUnit1 = AdUnit(100, 86400, 86500, 4, 86400, {tier1, tier2, tier3})

        tier4 = AdTier(2000, "http://www.example.com/tier/2000", 100, "Click 4", 86400, 1)
        stub(tier4, "isActive", true)
        adUnit2 = AdUnit(200, 85000, 87000, 1, 86400, {tier4})
        stub(adUnit2, "isActive", true)

        tier5 = AdTier(3000, "http://www.example.com/tier/3000", 100, "Click 5", 86400, 1)
        stub(tier5, "isActive", true)
        adUnit3 = AdUnit(300, 85000, 87000, 1, 86400, {tier5})
        stub(adUnit3, "isActive", true)

        local manifest = AdManifest()
        manifest.setAdUnits({adUnit1, adUnit2, adUnit3})
        subject = AdPresenter(manifest, fn__shouldShowTier)
    end)

    describe("getNextTiers", function()
        before_each(function()
            spy.on(cu, "SpriteButton")

            evolutions = {3, 6, 9}
        end)

        describe("when the first button's tier is inactive", function()
            before_each(function()
                stub(adUnit1, "isActive", true)
                stub(tier1, "isActive", false)
                stub(tier2, "isActive", true)
                stub(tier3, "isActive", true)

                buttons = subject.getNextTierButtons(1, fn__callback)
                buttons[1]:activate()
            end)

            it("should have returned/clicked the second tier", function()
                assert.equals(1001, tier.id)
            end)

            it("should have made call to create a button sprite", function()
                assert.stub(cu.SpriteButton).was.called()
            end)
        end)

        describe("when the first ad unit is inactive", function()
            before_each(function()
                stub(adUnit1, "isActive", false)

                buttons = subject.getNextTierButtons(1, fn__callback)
                buttons[1]:activate()
            end)

            it("should have returned/clicked the second ad unit's first tier", function()
                assert.equals(2000, tier.id)
            end)
        end)

        describe("when all buttons are inactive", function()
            before_each(function()
                stub(adUnit1, "isActive", false)
                stub(adUnit2, "isActive", false)
                stub(adUnit3, "isActive", false)

                buttons = subject.getNextTierButtons(1, fn__callback)
            end)

            it("should return no buttons", function()
                assert.equals(0, #buttons)
            end)
        end)
    end)

    describe("when getting ads that are greater than the total number of ads", function()
        local ads

        before_each(function()
            evolutions = {3, 6, 9}

            stub(adUnit1, "isActive", true)
            stub(tier1, "isActive", true)
            stub(tier2, "isActive", true)
            stub(tier3, "isActive", true)

            ads = subject.getNextTiers(4)
        end)

        it("should only return the total number of ads", function()
            assert.equals(3, #ads)
        end)

        it("should have returned the correct ads", function()
            assert.equals(tier1, ads[1])
            assert.equals(tier4, ads[2])
            assert.equals(tier5, ads[3])
        end)
    end)

    describe("when getting ads within the total number of ads", function()
        local ads

        before_each(function()
            evolutions = {3, 6, 9}

            stub(adUnit1, "isActive", true)
            stub(tier1, "isActive", true)
            stub(tier2, "isActive", true)
            stub(tier3, "isActive", true)

            ads = subject.getNextTiers(1)
        end)

        it("should have returned only one ad unit", function()
            assert.equals(1, #ads)
        end)

        it("should have returned the first ad", function()
            assert.equals(1000, ads[1].id)
        end)

        describe("call 2", function()
            before_each(function()
                ads = subject.getNextTiers(1)
            end)

            it("should have returned only one ad unit", function()
                assert.equals(1, #ads)
            end)

            it("should have returned the first ad", function()
                assert.equals(2000, ads[1].id)
            end)

            describe("call 3", function()
                before_each(function()
                    ads = subject.getNextTiers(1)
                end)

                it("should have returned only one ad unit", function()
                    assert.equals(1, #ads)
                end)

                it("should have returned the first ad", function()
                    assert.equals(3000, ads[1].id)
                end)

                describe("when querying for two ad units", function()
                    before_each(function()
                        ads = subject.getNextTiers(2)
                    end)

                    it("should have returned only one ad unit", function()
                        assert.equals(2, #ads)
                    end)

                    it("should have returned the first two ads", function()
                        assert.equals(1000, ads[1].id)
                        assert.equals(2000, ads[2].id)
                    end)

                    describe("call 4", function()
                        before_each(function()
                            ads = subject.getNextTiers(2)
                        end)

                        it("should have returned only one ad unit", function()
                            assert.equals(2, #ads)
                        end)

                        it("should have returned the last and first ad", function()
                            assert.equals(3000, ads[1].id)
                            assert.equals(1000, ads[2].id)
                        end)

                        describe("when the position is reset", function()
                            before_each(function()
                                subject.reset()
                                ads = subject.getNextTiers(1)
                            end)

                            it("should have returned the first button", function()
                                assert.equals(1000, ads[1].id)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end)

    describe("getNextTierButtons", function()
        local buttons
        
        describe("when the evolution is 3", function()
            before_each(function()
                evolutions = {3}

                stub(adUnit1, "isActive", true)
                stub(tier1, "isActive", true)
                stub(tier2, "isActive", true)
                stub(tier3, "isActive", true)

                buttons = subject.getNextTierButtons(1, fn__callback)
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

                it("should have returned tier w/ id 1000", function()
                    assert.equals(1000, tier.id)
                end)
            end)
        end)

        describe("when the evolution is 9", function()
            before_each(function()
                evolutions = {9}

                stub(adUnit1, "isActive", true)
                stub(tier1, "isActive", true)
                stub(tier2, "isActive", true)
                stub(tier3, "isActive", true)

                buttons = subject.getNextTierButtons(1, fn__callback)
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

                it("should have returned tier w/ id 1000", function()
                    assert.equals(1002, tier.id)
                end)
            end)
        end)
    end)
end)
