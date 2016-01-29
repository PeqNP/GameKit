require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Warning)

local Sound = require("shim.Sound")

describe("Sound", function()
    local subject
    local audio

    before_each(function()
        audio = cc.SimpleAudioEngine:getInstance()
        subject = Sound.getClass()()
    end)

    it("should have sound", function()
        assert.is_true(subject.IsOn())
    end)

    describe("isOn", function()
        describe("when turning the sound off", function()
            before_each(function()
                subject.SetOn(false)
            end)

            it("should have no sound", function()
                assert.is_false(subject.IsOn())
            end)

            describe("when turning the sound on", function()
                before_each(function()
                    subject.SetOn(true)
                end)

                it("should have sound", function()
                    assert.is_true(subject.IsOn())
                end)
            end)
        end)
    end)

    describe("play", function()
        local sourceId

        before_each(function()
            stub(audio, "playEffect")
        end)

        describe("when sound is off", function()
            before_each(function()
                subject.SetOn(false)
                sourceId = subject.Play("sound", true, 0, 0, 1)
            end)

            it("should not have played the sound", function()
                assert.is_false(sourceId)
            end)

            it("should not have played the effect", function()
                assert.stub(audio.playEffect).was.not_called()
            end)
        end)

        describe("when the sound is on", function()
            before_each(function()
                sourceId = subject.Play("sound", false, 0, 0.5, 1)
            end)

            it("should have played the sound", function()
                assert.stub(audio.playEffect).was.called_with(audio, "sound", false, 0, 0.5, 1)
            end)
        end)
    end)

    describe("stop", function()
        local sourceId

        before_each(function()
            stub(audio, "stopEffect")
        end)

        describe("when sound is off", function()
            before_each(function()
                subject.SetOn(false)
                subject.Stop(15)
            end)

            it("should not have stopped the effect", function()
                assert.stub(audio.stopEffect).was.not_called()
            end)
        end)

        describe("when the sound is on", function()
            before_each(function()
                sourceId = subject.Stop(15)
            end)

            it("should have stopped the sound", function()
                assert.stub(audio.stopEffect).was.called_with(audio, 15)
            end)
        end)
    end)
end)
