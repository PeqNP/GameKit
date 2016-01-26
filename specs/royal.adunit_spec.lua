require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

local AdConfig = require("royal.AdConfig")
local AdUnit = require("royal.AdUnit")
local AdTier = require("royal.AdTier")

AdConfig.singleton.setBasePath("/path/")

describe("AdUnit", function()
    local subject = false

    local id
    local startdate
    local enddate
    local maxclicks
    local waitsecs
    local tiers

    before_each(function()
        stub(io, "open")
        stub(io, "input")
        stub(io, "output")
        stub(io, "read")
        stub(io, "write")
        stub(io, "close")
    end)

    describe("when constructing from a dictionary (JSON)", function()
        before_each(function()
            -- JSON dictionary
            id = 10
            startdate = 4
            enddate = 6
            maxclicks = 4
            waitsecs = 86400
            tiers = {{id=1, url="http://example.com", reward=20, title="Click 1", waitsecs=100, maxclicks=1, config=0}}
            subject = AdUnit(id, startdate, enddate, waitsecs, maxclicks, tiers)
        end)

        it("should have set all values", function()
            assert.equals(10, subject.id)
            assert.equals(4, subject.startdate)
            assert.equals(6, subject.enddate)
            assert.equals(4, subject.maxclicks)
            assert.equals(86400, subject.waitsecs)

            local tiers = subject.getTiers()
            assert.equals(1, #tiers)
            for _, tier in ipairs(tiers) do
                assert.truthy(tier.kindOf(AdTier))
            end
        end)
    end)

    describe("when constructing from native objects", function()
        local tier1
        local tier2
        local tier3

        before_each(function()
            id = 10
            startdate = 4
            enddate = 6
            maxclicks = 4
            waitsecs = 86400
            tier1 = AdTier(1000, "http://www.example.com/tier/1000", 20, "Click 1", 86400, 1)
            tier2 = AdTier(1001, "http://www.example.com/tier/1001", 50, "Click 2", 86400, 1)
            tier3 = AdTier(1002, "http://www.example.com/tier/1002", 70, "Click 3", 86400, 1)
            tiers =  {tier1, tier2, tier3}
            subject = AdUnit(id, startdate, enddate, waitsecs, maxclicks, tiers)
        end)

        it("should have set all values", function()
            assert.equals(10, subject.id)
            assert.equals(4, subject.startdate)
            assert.equals(6, subject.enddate)
            assert.equals(4, subject.maxclicks)
            assert.equals(86400, subject.waitsecs)

            local tiers = subject.getTiers()
            assert.equals(3, #tiers)
            for _, tier in ipairs(tiers) do
                assert.truthy(tier.kindOf(AdTier))
            end
        end)

        describe("when the ad unit is active", function()
            before_each(function()
                stub(socket, "gettime", 5)
            end)

            describe("when all tiers are active", function()
                before_each(function()
                    stub(tier1, "isActive", true)
                    stub(tier2, "isActive", true)
                    stub(tier3, "isActive", true)
                end)

                it("should be active", function()
                    assert.truthy(subject.isActive())
                end)

                describe("when the max clicks has been reached", function()
                    before_each(function()
                        stub(tier1, "getNumClicks", 1)
                        stub(tier2, "getNumClicks", 2)
                        stub(tier3, "getNumClicks", 1)
                    end)

                    it("should be inactive", function()
                        assert.falsy(subject.isActive())
                    end)
                end)
            end)

            describe("when the first tier is inactive", function()
                before_each(function()
                    stub(tier1, "isActive", false)
                    stub(tier2, "isActive", false)
                    stub(tier3, "isActive", true)
                end)

                it("should still be active", function()
                    assert.truthy(subject.isActive())
                end)

                describe("when the max clicks has been reached", function()
                    before_each(function()
                        stub(tier1, "getNumClicks", 1)
                        stub(tier2, "getNumClicks", 2)
                        stub(tier3, "getNumClicks", 1)
                    end)

                    it("should be inactive", function()
                        assert.falsy(subject.isActive())
                    end)
                end)
            end)

            describe("when all of the tiers are inactive", function()
                before_each(function()
                    stub(tier1, "isActive", false)
                    stub(tier2, "isActive", false)
                    stub(tier3, "isActive", false)
                end)

                it("should still be active", function()
                    assert.falsy(subject.isActive())
                end)
            end)
        end)

        describe("when the ad just started", function()
            before_each(function()
                stub(socket, "gettime", 4)
            end)

            it("should not be active", function()
                assert.truthy(subject.isActive())
            end)
        end)

        describe("when the ad is near ending", function()
            before_each(function()
                stub(socket, "gettime", 6)
            end)

            it("should not be active", function()
                assert.truthy(subject.isActive())
            end)
        end)

        describe("when the ad unit hasn't started", function()
            before_each(function()
                stub(socket, "gettime", 3)
            end)

            it("should not be active", function()
                assert.falsy(subject.isActive())
            end)
        end)

        describe("when the ad unit has expired", function()
            before_each(function()
                stub(socket, "gettime", 7)
            end)

            it("should not be active", function()
                assert.falsy(subject.isActive())
            end)
        end)

        describe("setTiers", function()
            describe("when the tiers are a dictionary", function()
                local tiers
                local config

                before_each(function()
                    config = {evolution = 10}
                    tiers = {{
                        id = 2
                      , url = "http://www.example.com/ad2"
                      , reward = 20
                      , title = "Click 1"
                      , waitsecs = 86400
                      , maxclicks = 1
                      , config = config
                    }}

                    subject.setTiers(tiers)
                end)

                it("should have created AdTier objects from dictionary", function()
                    local tiers = subject.getTiers()
                    assert.equal(1, #tiers)
                    local tier = tiers[1]
                    assert.truthy(tier.kindOf(AdTier))
                    assert.equal(2, tier.id)
                    assert.equal("http://www.example.com/ad2", tier.url)
                    assert.equal(20, tier.reward)
                    assert.equal("Click 1", tier.title)
                    assert.equal(86400, tier.waitsecs)
                    assert.equal(1, tier.maxclicks)
                    assert.equal(config, tier.config)
                end)
            end)

            describe("when the tiers are AdTiers", function()
                local tier

                before_each(function()
                    tier = AdTier(2, "http://www.example.com/ad2", 20, 86400, 1, {evolution=2})
                    subject.setTiers({tier})
                end)

                it("should have created AdTier objects from dictionary", function()
                    local tiers = subject.getTiers()
                    assert.equal(1, #tiers)
                    assert.equal(tier, tiers[1])
                end)
            end)
        end)
    end)
end)
