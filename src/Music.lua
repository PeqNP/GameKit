--[[ Provides ability to turn on/off and fade music in/out.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.
--]]

require("Logger")

Music = Class()

function Music.new()
    local self = {}
    local tweenId
    local _bgPath
    local isOn = true

    function self.preload(path)
        cc.SimpleAudioEngine:getIntance():preloadMusic(path)
    end

    function self.play(path, loop)
        cc.SimpleAudioEngine:getInstance():playMusic(path, loop)
    end

    function self.stop(release)
        cc.SimpleAudioEngine:getInstance():stopMusic(release)
    end

    function self.setVolume(to)
        cc.SimpleAudioEngine:getInstance():setMusicVolume(to)
    end

    function self.turnOn(vol)
        Log.i("Music.on(%d)", vol)
        isOn = true
        self.fadeTo(vol, 0.5, nil, _bgPath)
    end

    function self.turnOff()
        Log.i("Music.off()")
        self.fadeTo(0, 0.5, function()
            self.stop(true)
        end)
        isOn = false
    end

    function self.fadeTo(to, length, bgPath)
        local p = Promise()
        -- Always set the bg path so that when the sound is turned back on
        -- it can be loaded.
        if bgPath then
            _bgPath = bgPath
        end
        if not isOn then
            Log.d("fadeTo Off")
            p.resolve()
            return p
        end
        Log.d("Starting music...")
        if tweenId then
            Log.w("Attempting to fade music in before the previous transition is over!")
            cu.unscheduleScriptEntry(tweenId)
            tweenId = nil
        end
        local from
        --if cc.SimpleAudioEngine:getInstance():isMusicPlaying() then
        if bgPath then
            -- This is for sanity only For some reason, isMusicPlaying always
            -- returns true... why? I don't know! But once it starts working
            -- again this should be removed and the above if statement re-instated.
            self.stop(true)
            Log.d("Not playing. Load: "..bgPath)
            from = 0.0
            self.play(bgPath, true)
            self.setVolume(0)
        else
            from = cc.SimpleAudioEngine:getInstance():getMusicVolume()
            Log.d("Playing music @ volume (%s)", from)
        end
        local tweenEndTime = gettime() + length
        local function tweenTick()
            local diff = tweenEndTime - gettime()
            if diff <= 0.0 then
                Log.d("Music finished")
                self.setVolume(to)
                cu.unscheduleScriptEntry(tweenId)
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
            self.setVolume(volume)
        end
        tweenId = cu.scheduleScriptEntry(tweenTick, 0, false)
        return p
    end

    return self
end
