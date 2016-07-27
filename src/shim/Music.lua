--
-- Provides ability to turn on/off and fade music in/out.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

local shim = require("shim.System")
local Promise = require("Promise")

local Music = Class()

local engine = cc.SimpleAudioEngine:getInstance()

function Music.new(self)
    local tweenId
    local _bgPath
    local isOn = true

    function self.Preload(path)
        Log.d("Music.Preload: path (%s)", path)
        engine:preloadMusic(path)
    end

    function self.Play(path, loop)
        engine:playMusic(path, loop)
    end

    function self.Stop(release)
        engine:stopMusic(release)
    end

    function self.SetVolume(to)
        engine:setMusicVolume(to)
    end
    
    function self.Pause()
        engine:pauseMusic()
    end

    function self.Resume()
        engine:resumeMusic()
    end

    function self.TurnOn(vol)
        Log.i("Music.on(%f)", vol)
        isOn = true
        self.FadeTo(vol, 0.5, _bgPath)
    end

    function self.TurnOff()
        Log.i("Music.off()")
        local promise = self.FadeTo(0, 0.5)
        promise.done(function()
            self.Stop(true)
        end)
        isOn = false
    end

    function self.FadeTo(to, length, bgPath)
        Log.d("Music.FadeTo: Will fade music to (%s) length (%s) path (%s)", to, length, bgPath)
        local p = Promise()
        -- Always set the bg path so that when the sound is turned back on
        -- it can be loaded.
        if bgPath then
            _bgPath = bgPath
        end
        if not isOn then
            Log.d("Music.FadeTo: Music not on")
            p.resolve()
            return p
        end
        Log.d("Music.FadeTo: Fading music")
        if tweenId then
            Log.w("Music.FadeTo: Attempting to fade music in before the previous transition is over!")
            shim.UnscheduleFunc(tweenId)
            tweenId = nil
        end
        local from
        -- Note: When a consumer provides a bgPath, it means they want to fade in to a new song.
        if bgPath then
            self.Stop(true)
            Log.d("Music.FadeTo: Currently not playing music. Will load path (%s)", bgPath)
            from = 0.0
            self.Play(bgPath, true)
            self.SetVolume(0)
        else
            from = engine:getMusicVolume()
            Log.d("Music.FadeTo: Currently playing music @ volume (%s)", from)
        end
        local tweenEndTime = gettime() + length
        local function onEnterFrame(event)
            local diff = tweenEndTime - gettime()
            if diff <= 0.0 then
                Log.d("Music.FadeTo: Finished fading music")
                self.SetVolume(to)
                shim.UnscheduleFunc(tweenId)
                tweenId = nil
                p.resolve()
                return
            end
            local delta = diff / length
            local volume
            -- Going down
            if from > to then
                volume = to + ((from - to) * delta)
            else
                -- Going up
                volume = to - ((to - from) * delta)
            end
            self.SetVolume(volume)
        end
        tweenId = shim.ScheduleFunc(onEnterFrame, 0, false)
        return p
    end
end

Singleton(Music)

return Music.singleton
