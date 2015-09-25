
require "lang.Signal"

require "specs.Cocos2d-x"

require "Logger"
require "Common"
require "Sound"
require "SoundBite"

require "game.Constants"

Log.setLevel(LogLevel.Warning)
Singleton(Sound)

describe("SoundBite", function()
    local subject

    describe("when the SoundType is Synchronous", function()
        before_each(function()
            subject = SoundBite(SoundType.Synchronous, LevelDepth.Near, "path-%d.mp3", 3)
        end)

        it("should not be playing", function()
            assert.is_false(subject.isPlaying())
        end)

        it("should have a type", function()
            assert.equals(SoundType.Synchronous, subject.getSoundType())
        end)

        it("should have a tag", function()
            assert.equals(LevelDepth.Near, subject.getTag())
        end)

        it("should have a filename", function()
            assert.equals("path-%d.mp3", subject.getFilename())
        end)

        it("should have 3 sound bites", function()
            assert.equals(3, subject.getNumBites())
        end)
        
        it("should provide an interpolated full path to file", function()
            assert.equals("path-1.mp3", subject.getSoundBiteFilename(1))
        end)

        it("should not be a looped sound", function()
            assert.falsy(subject.isLoop())
        end)

        it("should return all sound sound bites", function()
            local frames = subject.getAllSoundBites()
            assert.equals("path-1.mp3", frames[1])
            assert.equals("path-2.mp3", frames[2])
            assert.equals("path-3.mp3", frames[3])
        end)

        it("should return a random sound bite", function()
            assert.truthy(subject.getRandomSoundBite())
        end)

        it("should return the first sound bite", function()
            assert.equals("path-1.mp3", subject.getSoundBite())
        end)

        describe("setAttributes", function()
            before_each(function()
                stub(cu, "runAction")
                stub(Sound.singleton, "setPan")

                subject.setAttributes(-1, 0.5)
            end)

            it("should have set pan to -1", function()
                assert.equals(-1, subject.getPan())
            end)

            it("should have set gain to 1", function()
                assert.equals(0.5, subject.getGain())
            end)

            it("should NOT have set the pan", function()
                assert.stub(Sound.singleton.setPan).was_not.called()
            end)
            it("should NOT have faded the FX", function()
                assert.stub(cu.runAction).was_not.called()
            end)
        end)

        describe("nextSoundBite", function()
            local soundBite2
            local soundBite3
            local soundBite1

            before_each(function()
                subject.nextSoundBite()
                soundBite2 = subject.getSoundBite()
                subject.nextSoundBite()
                soundBite3 = subject.getSoundBite()
                subject.nextSoundBite()
                soundBite1 = subject.getSoundBite()
            end)

            it("should advance to sound bite 2", function()
                assert.equals("path-2.mp3", soundBite2)
            end)

            it("should advance to sound bite 3", function()
                assert.equals("path-3.mp3", soundBite3)
            end)

            it("should advance back to sound bite 1", function()
                assert.equals("path-1.mp3", soundBite1)
            end)
        end)

        describe("play", function()
            local sequence

            before_each(function()
                stub(Sound.singleton, "preload").and_return(1)
                stub(Sound.singleton, "play").and_return(-1)
                stub(Sound.singleton, "getLengthInSeconds").and_return(1)
                stub(cu, "runAction")

                cu.runAction = function(s)
                    sequence = s
                end
                subject.play(1, 0, 0.5)
                sequence:executeCalls()
            end)

            it("should have set interval", function()
                assert.equals(1, subject.getInterval())
            end)

            it("should have set pan", function()
                assert.equals(0, subject.getPan())
            end)

            it("should have set gain", function()
                assert.equals(0.5, subject.getGain())
            end)

            it("should have called API", function()
                local fxPath = subject.getSoundBiteFilename(1)
                assert.stub(Sound.singleton.play).was.called_with(fxPath, false, 0, 0, 0.5)
            end)

            it("should have scheduled the next sound to be played", function()
                assert.is_truthy(sequence)
            end)

            it("should have cached the length of the sound", function()
                assert.stub(Sound.singleton.getLengthInSeconds).was_called()
                assert.truthy(subject.getLength(1))
            end)

            it("should be playing", function()
                assert.is_true(subject.isPlaying())
            end)

            it("should have preloaded all the sounds", function()
                assert.stub(Sound.singleton.preload).was.called_with("path-1.mp3")
                assert.stub(Sound.singleton.preload).was.called_with("path-2.mp3")
                assert.stub(Sound.singleton.preload).was.called_with("path-3.mp3")
            end)

            describe("when the next sound should play", function()
            end)

            describe("stop", function()
                local promise
                local sequence

                before_each(function()
                    stub(Sound.singleton, "unload")

                    sequence = nil
                    cu.runAction = function(s)
                        sequence = s
                    end
                end)

                describe("when unloading sound", function()
                    before_each(function()
                        promise = subject.stop(true)
                    end)

                    it("should have returned a promise", function()
                        assert.truthy(promise)
                        assert.equals("Promise", promise.getClass())
                    end)

                    it("should have called runAction", function()
                        assert.truthy(sequence)
                    end)

                    it("should _still_ be playing", function()
                        assert.is_true(subject.isPlaying())
                    end)

                    describe("when the sound has stopped", function()
                        before_each(function()
                            sequence:executeCalls()
                        end)

                        it("should not be playing", function()
                            assert.is_false(subject.isPlaying())
                        end)

                        it("should have unloaded the sound", function()
                            assert.stub(Sound.singleton.unload).was.called_with("path-1.mp3")
                            assert.stub(Sound.singleton.unload).was.called_with("path-2.mp3")
                            assert.stub(Sound.singleton.unload).was.called_with("path-3.mp3")
                        end)
                    end)
                end)

                describe("when NOT unloading sound", function()
                    before_each(function()
                        subject.stop(false)
                    end)

                    it("should have returned a promise", function()
                        assert.truthy(promise)
                        assert.equals("Promise", promise.getClass())
                    end)

                    it("should have called runAction", function()
                        assert.truthy(sequence)
                    end)

                    describe("when the sound has stopped", function()
                        before_each(function()
                            sequence:executeCalls()
                        end)

                        it("should not be playing", function()
                            assert.is_false(subject.isPlaying())
                        end)

                        it("should NOT have unloaded the sound", function()
                            assert.stub(Sound.singleton.unload).was_not.called()
                        end)
                    end)
                end)
            end)
        end)

        describe("stop", function()
            local promise
            local pCalled

            describe("when unloading sound", function()
                before_each(function()
                    stub(Sound.singleton, "unload")

                    promise = subject.stop(true)

                    pCalled = false
                    promise.done(function()
                        pCalled = true
                    end)
                end)

                it("should have retuned a promise", function()
                    assert.truthy(promise)
                    assert.equals("Promise", promise.getClass())
                end)

                it("should have resolved the promise immediately", function()
                    assert.is_true(pCalled)
                end)

                it("should NOT have unloaded the sound", function()
                    -- It's not called because it was never loaded!
                    assert.stub(Sound.singleton.unload).was_not.called()
                end)
            end)

            describe("when NOT unloading sound", function()
                before_each(function()
                    stub(Sound.singleton, "unload")

                    promise = subject.stop(false)

                    pCalled = false
                    promise.done(function()
                        pCalled = true
                    end)
                end)

                it("should have retuned a promise", function()
                    assert.truthy(promise)
                    assert.equals("Promise", promise.getClass())
                end)

                it("should have resolved the promise immediately", function()
                    assert.is_true(pCalled)
                end)

                it("should NOT have unloaded the sound", function()
                    assert.stub(Sound.singleton.unload).was_not.called()
                end)
            end)
        end)
    end)

    describe("when the SoundType is Random", function()
    end)

    describe("when the SoundType is Loop", function()
        before_each(function()
            subject = SoundBite(SoundType.Loop, LevelDepth.Far, "path-%d.mp3", 3)
        end)

        it("should have set correct type", function()
            assert.equals(SoundType.Loop, subject.getSoundType())
        end)

        it("should have set the tag", function()
            assert.equals(LevelDepth.Far, subject.getTag())
        end)

        it("should be a loop", function()
            assert.truthy(subject.isLoop())
        end)
    end)
end)
