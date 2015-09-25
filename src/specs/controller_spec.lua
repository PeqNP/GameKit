
require "lang.Signal"

require "Logger"
Log.setLevel(LogLevel.Info)

require "specs.Cocos2d-x"

require "game.Config"
require "game.Controller"
require "game.SaveState"

Singleton(Config, "/path")
Singleton(SaveState)

describe("Controller", function()
    local subject
    local level
    local terra

    before_each(function()
        subject = Controller()
        level = subject.getLevel()
        terra = subject.getTerra()
    end)

    it("should have set all necessary variables on Terra", function()
        local c = terra.getCalendar()
        assert.equals("Calendar", c.getClass())
    end)

    it("should have created the level", function()
        assert.equals("Terra", terra.getClass())
        local l = subject.getLevel()
        assert.equals("ForestLevel", l.getClass())
        assert.equals(terra, l.getTerra())
    end)

    describe("start", function()
        before_each(function()
            stub(level, "start")

            subject.start()
        end)

        it("should have called start on level", function()
            assert.stub(level.start).was_called()
        end)
    end)

    describe("restart", function()
    end)
end)
