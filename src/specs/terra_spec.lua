
require "lang.Signal"

require "specs.Cocos2d-x"

require "Common"
require "Debug"
require "Logger"

require "game.Config"
require "game.Constants"
require "game.Calendar"
require "game.TerraCycle"
require "game.Terra"

Singleton(Config, "")
Log.setLevel(LogLevel.Error)

describe("Terra", function()
    local subject
    local actors
    local calendar
    local terraCycle
    local precip
    local wind

    before_each(function()
        precip = Precipitation({}, 10)
        wind = Wind({}, 20)
        calendar = Calendar(1, 1)
        subject = Terra(calendar, DayCycle.Morning, precip, wind)
        actors = subject.getActors()
    end)

    it("should not have initially set location", function()
        assert.falsy(subject.getLevel())
    end)

    it("should contain only actors, not TerraCycle", function()
        assert.equals(6, #actors)
        assert.equals(Bird, actors[1].getActorClass())
        assert.equals(Cricket, actors[2].getActorClass())
        assert.equals(Crow, actors[3].getActorClass())
        assert.equals(Frog, actors[4].getActorClass())
        assert.equals(Wolf, actors[5].getActorClass())
        assert.equals("Dust", actors[6].getClass())
    end)

    it("should have set all of the SoundBites", function()
        function testSoundBite(actor)
            local soundBite = actor.getSoundBite()
            assert.truthy(soundBite)
            assert.equals("SoundBite", soundBite.getClass())
        end
        for _, actor in ipairs(actors) do
            if actor.getClass() == "AnimalGroup" then
                for _, animal in ipairs(actor.getActors()) do
                    testSoundBite(animal)
                end
            else
                testSoundBite(actor)
            end
        end
    end)

    it("should have set terraCycle", function()
        assert.truthy(subject.getTerraCycle())
    end)

    it("should not yet have set the nextCycleTime", function()
        assert.is.falsy(subject.getNextCycleTime())
    end)

    describe("start", function()
        before_each(function()
            for i, actor in ipairs(actors) do
                stub(actor, "start")
            end
            -- This isn't going to work... stubs don't call the method.
            cu.scheduleScriptEntry = function()
                return 1
            end
            stub(cu, "scheduleScriptEntry").and_return(1)

            subject.start(1)
        end)

        it("should have set the nextCycleTime", function()
            assert.is_true(subject.getNextCycleTime() > 0)
        end)

        it("should have called scheduleFunction", function()
            assert.stub(cu.scheduleScriptEntry).was.called()
        end)

        it("should have called all actor start methods", function()
            for i, actor in ipairs(actors) do
                assert.stub(actor.start).was.called_with(1)
            end
        end)

        it("should have set the Terra.location", function()
            assert.equals(1, subject.getLevel())
        end)

        describe("stop", function()
            before_each(function()
                for i, actor in ipairs(actors) do
                    stub(actor, "stop")
                end
                stub(cu, "unscheduleScriptEntry")

                subject.stop()
            end)

            it("should have called all actor stop methods", function()
                for i, actor in ipairs(actors) do
                    assert.stub(actor.stop).was.called()
                end
            end)

            it("should not have called unscheduleFunction as level was never started", function()
                assert.stub(cu.unscheduleScriptEntry).was.called()
            end)
        end)
    end)

    describe("stop", function()
        before_each(function()
            stub(cu, "unscheduleScriptEntry")
            subject.stop()
        end)

        it("should not have called unscheduleFunction as level was never started", function()
            assert.stub(cu.unscheduleScriptEntry).was.not_called()
        end)
    end)

    describe("setTerraCycle", function()
        local currCycle = false

        before_each(function()
            for i, actor in ipairs(actors) do
                stub(actor, "nextCycle")
            end

            currCycle = TerraCycle(Season.Hibernal, DayCycle.Afternoon, 30, 40)
            subject.setTerraCycle(currCycle)
        end)

        it("should have set the nextCycleTime", function()
            assert.is_true(subject.getNextCycleTime() > 0)
        end)

        it("should have started a new cycle", function()
            local cycle = subject.getTerraCycle()
            assert.truthy(cycle)
            assert.equals("TerraCycle", cycle.getClass())
            assert.not_equals(currCycle, cycle)
        end)

        it("should have set the cycle attribs with the current and next cycle", function()
            local nextCycle = subject.getTerraCycle()
            for i, actor in ipairs(actors) do
                assert.stub(actor.nextCycle).was.called_with(currCycle, nextCycle)
            end
        end)
    end)
end)
