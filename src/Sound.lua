--[[
  Provides ability to play and stop a given sound effect.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

Sound = Class()

local engine = cc.SimpleAudioEngine:getInstance()

function Sound.new(self)
    local isOn = true

    function self.setOn(on)
        isOn = on
    end

    function self.isOn()
        return isOn
    end

    function self.setVolume(to)
        engine:setEffectsVolume(to)
    end

    function self.play(path, loop, pitch, pan, gain)
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

    function self.stop(fxId)
        if not isOn then
            Log.i("playSound - Off")
            return
        end
        engine:stopEffect(fxId)
    end

    function self.isPlaying(fxId)
        return engine:effectIsPlaying(fxId)
    end

    function self.preload(path)
        engine:preloadEffect(path)
    end

    function self.unload(path)
        engine:unloadEffect(path)
    end

    function self.setPan(fxId, pan)
        engine:setEffectPan(fxId, pan)
    end

    function self.getLengthInSeconds(fxId)
        return engine:getEffectLengthInSeconds(fxId)
    end
end

function Sound.getEngine()
    return engine
end

function Sound.setEngine(e)
    engine = e
end
