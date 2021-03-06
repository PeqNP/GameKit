require "specs.Cocos2d-x"
require "lang.Signal"
require "Logger"

Log.setLevel(LogLevel.Warning)

local shim = require("shim.System")
local Music = require("shim.Music")

describe("Music", function()
    local subject

    before_each(function()
        subject = Music.getClass()()
    end)

    describe("when the music is turned on", function()
        local scriptId = false
        local tickFunction = false

        local function scheduleScriptEntry(fn, rp, paused)
            tickFunction = fn
            return 1
        end

        before_each(function()
            scriptId = 1
            stub(shim, "UnscheduleScriptEntry")
            shim.ScheduleFunc = scheduleScriptEntry
        end)

        describe("fadeTo", function()
            local promise = false

            before_each(function()
                promise = subject.FadeTo(0, 0)
                stub(promise, "resolve")
            end)

            it("should not have called callback yet", function()
                assert.stub(promise.resolve).was.not_called()
            end)

            describe("finished fading out", function()
                before_each(function()
                    tickFunction()
                end)

                it("should have called callback", function()
                    assert.stub(promise.resolve).was.called()
                end)
            end)
        end)
    end)

    -- @todo Test when music is turned off when on. Make sure SimpleAudioEngine->stop() is called (or self.stop)
    -- @todo Test when music is turned on after being turned off. Make sure SimpleAudioEngine->play() is called (or self.play)

end)
