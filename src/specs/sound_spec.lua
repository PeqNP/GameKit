
require "lang.Signal"

require "specs.Cocos2d-x"

require "Logger"
require "Sound"

Log.setLevel(LogLevel.Warning)

describe("Sound", function()
    local subject
    local audio

    before_each(function()
        audio = cc.SimpleAudioEngine()
        Sound.setEngine(audio)

        subject = Sound()
    end)

    it("should have sound", function()
        assert.is_true(subject.isOn())
    end)

    describe("isOn", function()
        describe("when turning the sound off", function()
            before_each(function()
                subject.setOn(false)
            end)

            it("should have no sound", function()
                assert.is_false(subject.isOn())
            end)

            describe("when turning the sound on", function()
                before_each(function()
                    subject.setOn(true)
                end)

                it("should have sound", function()
                    assert.is_true(subject.isOn())
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
                subject.setOn(false)
                sourceId = subject.play("sound", true, 0, 0, 1)
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
                sourceId = subject.play("sound", false, 0, 0.5, 1)
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
                subject.setOn(false)
                subject.stop(15)
            end)

            it("should not have stopped the effect", function()
                assert.stub(audio.stopEffect).was.not_called()
            end)
        end)

        describe("when the sound is on", function()
            before_each(function()
                sourceId = subject.stop(15)
            end)

            it("should have stopped the sound", function()
                assert.stub(audio.stopEffect).was.called_with(audio, 15)
            end)
        end)
    end)
end)
