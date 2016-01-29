--
-- Provides ability to play and stop a given sound effect.
--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local Sound = Class()

local engine = cc.SimpleAudioEngine:getInstance()

function Sound.new(self)
    local isOn = true

    function self.SetOn(on)
        isOn = on
    end

    function self.IsOn()
        return isOn
    end

    function self.SetVolume(to)
        engine:setEffectsVolume(to)
    end

    function self.Play(path, loop, pitch, pan, gain)
        pitch = pitch and pitch or 1
        pan = pan and pan or 0
        gain = gain and gain or 1
        if not isOn then
            Log.i("playSound - Off")
            return false
        end
        if not _repeat then
            _repeat = false
        end
        return engine:playEffect(path, loop, pitch, pan, gain)
    end

    function self.Stop(fxId)
        if not isOn then
            Log.i("playSound - Off")
            return
        end
        engine:stopEffect(fxId)
    end

    function self.IsPlaying(fxId)
        return engine:effectIsPlaying(fxId)
    end

    function self.Preload(path)
        engine:preloadEffect(path)
    end

    function self.Unload(path)
        engine:unloadEffect(path)
    end

    function self.SetPan(fxId, pan)
        engine:setEffectPan(fxId, pan)
    end

    function self.GetLengthInSeconds(fxId)
        return engine:getEffectLengthInSeconds(fxId)
    end
end

Singleton(Sound)

return Sound.singleton
