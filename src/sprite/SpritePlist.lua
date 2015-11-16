--[[
  Provides SpritePlist data structure loading routines. This loads
  Sprite sheets from a plist.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

require "Promise"
require "sprite.Frame"

SpritePlist = Class()

local plists = {}

function SpritePlist.register(name, texture)
    local plist = plists[name]
    if not plist then
        plists[name] = texture
    end
end

function SpritePlist.clean(name)
    local plist = plists[name]
    if plist then
        plist.clean()
    end
end

function SpritePlist.new(self)
    local textureName
    local frames
    local scale

    local imageName
    local plistName

    function self.init(_textureName, _frames, _scale)
        textureName = _textureName
        frames = _frames
        scale = _scale

        imageName = textureName..".png"
        plistName = textureName..".plist"

        SpritePlist.register(textureName, self)
    end

    local function getFrameName(frame)
        return string.format("%s-frame-%d.png",  textureName, frame.number)
    end

    local function loadPlist()
        Log.i("Loading texture (%s)...", textureName)
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistName)
    end

    --[[ Load frames asynchronously. ]]--
    function self.loadFrames()
        local promise = Promise()
        if #frames == 0 then
            Log.s("No frames provided for texture (%s)!", textureName)
            promise.reject()
            return promise
        end
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(imageName)
        -- Already in memory.
        if texture then
            promise.resolve(self.getFrames())
            return promise
        end
        -- Load texture into memory.
        local function textureLoaded(texture)
            loadPlist()
            promise.resolve(self.getFrames())
        end
        --[[ Until further notice. This fails on some Android devices and
        even occassionaly fails to work on iOS.
        cc.Director:getInstance():getTextureCache():addImageAsync(imageName, textureLoaded)
        --]]
        cc.Director:getInstance():getTextureCache():addImage(imageName)
        textureLoaded()
        return promise
    end

    --[[ Returns frames for this sprite sheet. ]]--
    function self.getFrames()
        if #frames == 0 then
            return {}
        end
        -- Load plist only once. It may have already been loaded from async
        -- func.
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(imageName)
        if not texture then
            loadPlist()
        end
        local tmpFrames = {}
        for idx, frame in pairs(frames) do
            local isNumber = type(frame) == "number"
            if isNumber then
                frame = Frame(frame) -- Convert to frame.
            end
            local name = getFrameName(frame)
            local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
            if not spriteFrame then
                Log.w("Failed to find sprite frame (%s)", name)
            elseif isNumber then
                local size = spriteFrame:getOriginalSize()
                frame.bbox = cc.rect(0, 0, size.width, size.height)
            end
            if isNumber then -- @note Must be done for each condition above.
                frames[idx] = frame
            end
            -- else, cache hit!
            frame.sprite = spriteFrame
            tmpFrames[idx] = frame
        end
        return tmpFrames
    end

    function self.clean()
        Log.i("Cleaning texture (%s)...", textureName)
        for idx, frame in pairs(frames) do
            cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(getFrameName(frame))
        end
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plistName)
        cc.Director:getInstance():getTextureCache():removeTextureForKey(imageName)
        --Log.d(debug.traceback())
        --cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
    end
end
