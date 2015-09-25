
require "lang.Signal"

require "Logger"

require "game.TerraCycle"
require "game.animal.Bird"

describe("Bird", function()
    local subject
    local soundBite

    before_each(function()
        soundBite = {}
        subject = Bird(soundBite)
    end)

    it("should have set the sound bite", function()
        assert.equals(soundBite, subject.getSoundBite())
    end)

    it("should return a value between 2-4 (frequent) when dawn/morning", function()
        local v = subject.getInterval(TerraCycle(Season.Vernal, DayCycle.Dawn), nil)
        assert.truthy(integer.between(v, 2, 4))
    end)

    it("should return a value between 4-6 (less frequent) when afternoon", function()
        local v = subject.getInterval(TerraCycle(Season.Vernal, DayCycle.Afternoon), nil)
        assert.truthy(integer.between(v, 4, 6))
    end)

    it("should return a value between 6-7 (infrequent) when evening", function()
        local v = subject.getInterval(TerraCycle(Season.Vernal, DayCycle.Evening), nil)
        assert.truthy(integer.between(v, 6, 7))
    end)

    it("should be false when midnight", function()
        local v = subject.getInterval(TerraCycle(Season.Vernal, DayCycle.Midnight), nil)
        assert.falsy(v)
    end)

    it("should be false when dusk", function()
        local v = subject.getInterval(TerraCycle(Season.Vernal, DayCycle.Dusk), nil)
        assert.falsy(v)
    end)

    it("should be false when midnight", function()
        local v = subject.getInterval(TerraCycle(Season.Vernal, DayCycle.Midnight), nil)
        assert.falsy(v)
    end)
end)

describe("Bird.getMaxAllowedForTerraCycle", function()
    it("should have 60% animals and Prevernal and Morning and zero precip/wind", function()
        assert.equals(0.6, Bird.getMaxAllowedForTerraCycle(TerraCycle(Season.Prevernal, DayCycle.Morning, 0.0, 0.0)))
    end)

    it("should have 0% animals when Midnight, regardless of the other attrs", function()
        assert.equals(0.0, Bird.getMaxAllowedForTerraCycle(TerraCycle(Season.Prevernal, DayCycle.Midnight, 0.0, 0.0)))
    end)

    it("should have 80% of 60% animals and Prevernal and Afternoon and zero precip/wind", function()
        assert.equals(0.48, Bird.getMaxAllowedForTerraCycle(TerraCycle(Season.Prevernal, DayCycle.Afternoon, 0.0, 0.0)))
    end)
end)
