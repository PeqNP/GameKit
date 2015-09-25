
require "lang.Signal"

require "Logger"

require "game.Weather"

describe("Weather", function()
    local subject
    local soundBite

    before_each(function()
        soundBite = {}
        subject = Weather(soundBite)
    end)

    it("should have set the sound bite", function()
        assert.equals(soundBite, subject.getSoundBite())
    end)
end)
