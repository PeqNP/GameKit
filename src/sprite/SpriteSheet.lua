--[[
  Provides SpriteSheet data structure loading routines.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

require "sprite.Frame"

SpriteSheet = Class()

local sheets = {}

function SpriteSheet.register(name, texture)
    local sheet = sheets[name]
    if not sheet then
        sheets[name] = texture
    end
end

function SpriteSheet.clean(name)
    local sheet = sheets[name]
    if sheet then
        sheet.clean()
    end
end

function SpriteSheet.new(self)
    local textureName
    local frames
    local cols
    local rows

    -- Computed width/height of each frame. These will be set only after
    -- getFrames() is called.
    self.width = false
    self.height = false

    function self.init(_textureName, _frames, _cols, _rows)
        textureName = _textureName
        frames = _frames
        cols = _cols
        rows = _rows

        SpriteSheet.register(textureName, self)
    end

    local function getFrameName(frame)
        return textureName .. frame.number
    end

    --[[ Load sprite sheet frames asynchronously. ]]--
    function self.loadFrames(callback)
        if #frames == 0 then
            callback({})
            return
        end
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(textureName)
        -- Already in memory.
        if texture then
            callback(self.getFrames())
            return
        end
        -- Load texture into memory.
        local function textureLoaded(texture)
            Log.i("Finished loading texture (%s)...", textureName)
            callback(self.getFrames())
        end
        --[[ Until further notice. This fails on some Android devices and
        even occassionaly fails to work on iOS.
        cc.Director:getInstance():getTextureCache():addImageAsync(textureName, textureLoaded)
        --]]
        cc.Director:getInstance():getTextureCache():addImage(textureName)
        textureLoaded()
        return promise
    end

    --[[ Load and return sprite sheet frames. ]]--
    function self.getFrames()
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(textureName)
        -- Synchronously load texture.
        if not texture then
            Log.i("Sheet: Loading texture (%s)...", textureName)
            texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
        end
        self.width = texture:getPixelsWide() / cols
        self.height = texture:getPixelsHigh() / rows
        --Log.d("Texture size w(%s) h(%s)", self.width, self.height)
        local orderedFrames = {}
        for idx, frame in pairs(frames) do
            if type(frame) == "number" then
                frame = Frame(frame) -- Convert to frame.
                frame.bbox = cc.rect(0, 0, self.width, self.height)
                frames[idx] = frame
            end
            local col = (frame.number-1) % cols
            local row = math.floor((frame.number-1) / cols)
            local name = getFrameName(frame)
            local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
            if not spriteFrame then
                local rect = cc.rect(col*self.width, row*self.height, self.width, self.height)
                --Log.d("idx: (%s), frameNum: (%s), r: (x=%s, y=%s, w=%s, h=%s)", idx, frame.number, rect.x, rect.y, rect.width, rect.height)
                spriteFrame = cc.SpriteFrame:createWithTexture(texture, rect)
                cc.SpriteFrameCache:getInstance():addSpriteFrame(spriteFrame, name)
            end
            -- else, cache hit!
            frame.sprite = spriteFrame
            orderedFrames[idx] = frame
        end
        return orderedFrames
    end

    function self.clean()
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(textureName)
        if not texture then
            return
        end
        Log.i("Cleaning texture (%s)", textureName)
        for idx, frame in pairs(frames) do
            cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(getFrameName(frame))
        end
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromTexture(texture)
        cc.Director:getInstance():getTextureCache():removeTextureForKey(textureName)
        --cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
    end
end
