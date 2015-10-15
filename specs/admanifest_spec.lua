require "lang.Signal"

require "royal.AdManifest"
require "royal.AdUnit"

describe("AdManifest", function()
    local subject

    local version
    local created
    local ttl
    local units

    before_each(function()
        version = 1
        created = 1433289600
        ttl = 86500
        units = {{
            id = 1
          , startdate = 15
          , enddate = 16
          , waitsecs = 30
          , maxclicks = 10
          , tiers = {}
        }}
        subject = AdManifest(version, created, ttl, units)
    end)

    it("should have set all values", function()
        assert.equals(1, subject.getVersion())
        assert.equals(1433289600, subject.getCreated())
        assert.equals(86500, subject.getTtl())
    end)

    it("should have created AdUnit from dictionary", function()
        local units = subject.getAdUnits()
        assert.equal(1, #units)
        local unit = units[1]
        assert.equal("AdUnit", unit.getClass())
        assert.equal(1, unit.id)
        assert.equal(15, unit.startdate)
        assert.equal(16, unit.enddate)
        assert.equal(30, unit.waitsecs)
        assert.equal(10, unit.maxclicks)
    end)

    describe("isActive", function()
        it("should be active if time is less than created time", function()
            assert.truthy(subject.isActive(1433289599))
        end)

        it("should be active if time is equal to created time", function()
            assert.truthy(subject.isActive(1433289600))
        end)

        it("should be inactive if time is greater than created time", function()
            assert.falsy(subject.isActive(1433289601))
        end)
    end)

    describe("setAdUnits", function()
        describe("when the ad tiers are a dictionary", function()
            before_each(function()
                units = {{
                    id = 4
                  , startedate = 1
                  , enddate = 2
                  , waitsecs = 30
                  , maxclicks = 2
                  , tiers = {}
                }}
                subject.setAdUnits(units)
            end)

            it("should have set the ad units", function()
                local adUnits = subject.getAdUnits()
                assert.equals(1, #adUnits)
                local unit = adUnits[1]
                assert.equal("AdUnit", unit.getClass())
                assert.equal(4, unit.id)
            end)
        end)

        describe("when the ad tiers are objects", function()
            local unit

            before_each(function()
                unit = AdUnit(5, 4, 5, 30, 1, {})
                subject.setAdUnits({unit})
            end)

            it("should have set the ad units", function()
                local adUnits = subject.getAdUnits()
                assert.equals(1, #adUnits)
                assert.equal(unit, adUnits[1])
            end)
        end)
    end)
end)
