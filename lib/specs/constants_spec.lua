
require "src.lang.Signal"

require "Common"
require "game.Constants"

describe("Constants", function()
    it("should have 6 seasons", function()
        assert.equals(1, Season.MIN)
        assert.equals(6, Season.MAX)
    end)

    it("should contain 6 day cycles", function()
        assert.equals(1, DayCycle.MIN)
        assert.equals(6, DayCycle.MAX)
    end)

    it("should have level depths", function()
        assert.equals(1, LevelDepth.MIN)
        assert.equals(2, LevelDepth.MAX)
    end)

    it("should have weather strengths", function()
        assert.equals(1, WeatherStrength.MIN)
        assert.equals(4, WeatherStrength.MAX)
    end)
end)
