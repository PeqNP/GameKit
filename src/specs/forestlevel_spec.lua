
require "lang.Signal"
require "Common"
require "Logger"

Log.setLevel(LogLevel.Warning)

require "src.specs.Cocos2d-x"

require "Music"
Singleton(Music)

require "game.Config"
Singleton(Config, "/path")

require "game.SaveState"
Singleton(SaveState)

require "game.Constants"
require "game.Calendar"
require "game.TerraCycle"
require "game.Terra"
require "game.level.ForestLevel"

describe("ForestLevel", function()
    local subject
    local terra
    local environment
    local calendar
    local terraCycle

    before_each(function()
        calendar = Calendar(1, 1)
        terra = Terra(calendar, DayCycle.Morning, Precipitation({}, 1), Wind({}, 2))
        stub(terra, "start")

        subject = ForestLevel(terra)

        environment = subject.getEnvironment()
        stub(environment, "start")
    end)

    it("should not be started", function()
        assert.falsy(subject.isStarted())
    end)

    it("should have a contentSize", function()
        assert.truthy(subject.getContentSize())
    end)

    it("should be a Near depth", function()
        assert.equals(LevelDepth.Near, subject.getLevelDepth())
    end)

    it("should have created its respective environment (the forest canopy)", function()
        assert.truthy(environment)
        assert.equals("ForestCanopy", environment.getClass())
    end)

    it("should not have started environment", function()
        assert.stub(environment.start).was.not_called()
    end)

    it("should not have started Terra", function()
        assert.stub(terra.start).was.not_called()
    end)

    it("should have created an FXProcessor", function()
        local fx = subject.getFXProcessor()
        assert.truthy(fx)
        assert.equals("FXProcessor", fx.getClass())
    end)

    describe("start", function()
        before_each(function()
            stub(subject.layer, "scheduleUpdateWithPriorityLua")

            subject.start()
        end)

        it("should have started", function()
            assert.truthy(subject.isStarted())
        end)

        it("should have scheduled function", function()
            assert.stub(subject.layer.scheduleUpdateWithPriorityLua).was.called()
        end)

        it("should have started environment", function()
            assert.stub(environment.start).was.called()
        end)

        it("should have started Terra", function()
            assert.stub(terra.start).was.called()
        end)

        describe("stop", function()
            local stopPromise = false
            local musicPromise = false

            before_each(function()
                stub(subject.layer, "unscheduleUpdate")
                stub(terra, "stop")
                stub(environment, "stop")

                musicPromise = Promise()
                stub(Music.singleton, "fadeTo").and_return(musicPromise)

                stopPromise = subject.stop()
                stub(stopPromise, "resolve")
            end)

            it("should NOT have stopped yet until music is done playing", function()
                assert.truthy(subject.isStarted())
            end)

            it("should have unscheduled function", function()
                assert.stub(subject.layer.unscheduleUpdate).was.called()
            end)

            it("should have stopped environment", function()
                assert.stub(environment.stop).was.called()
            end)

            it("should have stopped Terra", function()
                assert.stub(terra.stop).was.called()
            end)

            it("should have faded music", function()
                assert.stub(Music.singleton.fadeTo).was_called()
            end)

            it("should not have resolved promise until music finishes fading out", function()
                assert.stub(stopPromise.resolve).was.not_called()
            end)

            describe("when the music finishes fading out", function()
                before_each(function()
                    musicPromise.resolve()
                end)

                it("should have stopped", function()
                    assert.falsy(subject.isStarted())
                end)

                it("should have resolved promise after music faded", function()
                    assert.stub(stopPromise.resolve).was.called()
                end)
            end)
        end)
    end)
end)
