--[[ Provides the ability to load the resource paths for a group
     of sound bites.

@fixme tag may not make sense to have on this class. May need a
subclass as depths can change between games. That being said, there is
no logic in this class that deals with the depth. So it's probably fine
for now.

When the sound begins, schedule timer. That promise needs to be returned
when starting as well so that the next interval starts.

@param 2015 Upstart Illustration LLC. All rights reserved.

--]]

require "Promise"

SoundType = enum(1
  , 'Synchronous'
  , 'Random'
  , 'Loop'
)

SoundBite = Class()

function SoundBite.new(soundType, tag, filename, numBites)
    local self = {}

    local sourceId
    local counter = 1
    local interval
    local pan
    local gain
    local lengths = {}
    local preloaded = {}

    function self.getFilename()
        return filename
    end

    function self.getNumBites()
        return numBites
    end

    function self.isPlaying()
        return sourceId ~= nil
    end

    function self.getSoundType()
        return soundType
    end

    function self.isLoop()
        return soundType == SoundType.Loop
    end

    function self.getTag()
        return tag
    end

    --[[ Get full path to sound file. ]]--
    function self.getSoundBiteFilename(num)
        -- @todo Get full path of sound resource
        return string.format(filename, num)
    end

    --[[ Advances to the next sound bite, depending on the type. ]]--
    function self.nextSoundBite()
        counter = counter + 1
        if counter > numBites then
            counter = 1
        end
    end

    --[[ Returns the current sound bite being played. ]]--
    function self.getSoundBite()
        return self.getSoundBiteFilename(counter)
    end

    function self.getLength(num)
        return lengths[num]
    end

    --[[ Return list of all sound bites. ]]--
    function self.getAllSoundBites()
        local frames = {}
        for biteNum=1, numBites do
            table.insert(frames, self.getSoundBiteFilename(biteNum))
        end
        return frames
    end

    function self.getRandomSoundBite()
        local biteNum = math.random(1, numBites)
        return self.getSoundBiteFilename(biteNum)
    end

    local function startPlaying()
        local path = self.getSoundBiteFilename(counter)
        sourceId = Sound.singleton.play(path, self.isLoop(), 0, pan, gain)
        -- Get the length of the sound, if we don't already have it.
        if not lengths[counter] then
            lengths[counter] = Sound.singleton.getLengthInSeconds(path)
        end
        Log.d("Playing: %s", path)
    end

    --[[ Plays a sound that is NOT a looping sound. This moves to the
         sound bite once the current sound bite finishes. ]]--
    local function playSequence()
        startPlaying()
        local playTime = gettime() + lengths[counter] + interval
        cu.runAction(cu.Sequence(cu.Delay(playTime), cu.Call(function()
            sourceId = nil
            self.nextSoundBite()
            playSequence()
        end)))
    end

    local function preloadAllSounds()
        -- Do not attempt to preload sounds that are already preloaded.
        if #preloaded > 0 then return end
        for biteNum=1, numBites do
            local path = self.getSoundBiteFilename(biteNum)
            Sound.singleton.preload(path)
            table.insert(preloaded, biteNum)
        end
    end

    function self.play(i, p, g)
        -- Wait until effect is done playing. Then play the next one.
        if self.isPlaying() then
            -- Do not play if looping.
            if self.isLoop() then
                Log.w("Sound is looping. Will not play!")
                return
            end
            local p = self.stop()
            p.done(function()
                self.play(i, p, g)
            end)
            return
        end
        interval = i
        pan = p
        gain = g
        if self.isLoop() then
            startPlaying()
        else
            -- Preload all sound FX.
            preloadAllSounds()
            -- Wait a bit before playing. These allows easing into transitions.
            -- It also makes it so all sounds don't start at the same time.
            local playTime = math.random(1, 7)
            cu.runAction(cu.Sequence(cu.Delay(playTime), cu.Call(function()
                playSequence()
            end)))
        end
    end

    local function unloadAllSounds()
        for _, biteNum in ipairs(preloaded) do
            local path = self.getSoundBiteFilename(biteNum)
            Sound.singleton.unload(path)
        end
        preloaded = {}
    end

    function self.stop(unload)
        local p = Promise()
        if self.isPlaying() then
            -- Prevent the next sound from playing.
            if playPromise then
                playPromise.reject()
            end
            -- @fixme Is this really the way to do it?
            cu.runAction(cu.Sequence(
                cu.FadeEffectTo(sourceId, 0.5, 0.0, true)
              , cu.Call(function()
                    sourceId = nil
                    if unload then unloadAllSounds() end
                    p.resolve(self)
            end)))
        else
            sourceId = nil
            if unload then unloadAllSounds() end
            p.resolve(self)
        end
        return p
    end

    function self.setAttributes(p, g)
        if sourceId then
            if pan ~= p then
                Sound.singleton.setPan(sourceId, p)
            end
            if gain ~= g then
                cu.runAction(cu.FadeEffectTo(sourceId, 0.5, g, false))
            end
        end
        pan = p
        gain = g
    end

    function self.getInterval()
        return interval
    end

    function self.getPan()
        return pan
    end

    function self.getGain()
        return gain
    end

    return self
end
