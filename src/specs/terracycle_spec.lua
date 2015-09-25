
require "lang.Signal"

require "specs.Cocos2d-x"

require "Common"

require "game.Constants"
require "game.TerraCycle"

describe("TerraCycle", function()
    local subject

    before_each(function()
        subject = TerraCycle(Season.Prevernal, DayCycle.Dusk, 1, 2)
    end)

    it("should have set season", function()
        assert.equals(Season.Prevernal, subject.getSeason())
    end)

    it("should have cycle", function()
        assert.equals(DayCycle.Dusk, subject.getDayCycle())
    end)

    it("should have rain", function()
        assert.equals(1, subject.getPrecipitation())
    end)

    it("should have wind", function()
        assert.equals(2, subject.getWind())
    end)
end)
