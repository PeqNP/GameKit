--[[
  Provides SpriteSheet data structure loading routines.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

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

function SpriteSheet.new(_texture, _frames, _cols, _rows)
    local self = {}

    -- Computed width/height of each frame. These will be set only after
    -- getFrames() is called.
    self.width = false
    self.height = false

    local function getFrameName(frame)
        return _texture .. frame.number
    end

    --[[ Load sprite sheet frames asynchronously. ]]--
    function self.loadFrames(callback)
        if #_frames == 0 then
            callback({})
            return
        end
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(_textureName)
        -- Already in memory.
        if texture then
            callback(self.getFrames())
            return
        end
        -- Load texture into memory.
        local function textureLoaded(texture)
            Log.i("Loading texture asynchonously (%s)...", _texture)
            callback(self.getFrames())
        end
        cc.Director:getInstance():getTextureCache():addImageAsync(_texture, textureLoaded)
    end

    --[[ Load and return sprite sheet frames. ]]--
    function self.getFrames()
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(_texture)
        -- Synchronously load texture.
        if not texture then
            Log.i("Loading texture (%s)...", _texture)
            texture = cc.Director:getInstance():getTextureCache():addImage(_texture)
        end
        self.width = texture:getPixelsWide() / _cols
        self.height = texture:getPixelsHigh() / _rows
        --Log.d("Texture size w(%s) h(%s)", self.width, self.height)
        local frames = {}
        for idx, frame in pairs(_frames) do
            if type(frame) == "number" then
                frame = Frame(frame) -- Convert to frame.
                frame.bbox = cc.rect(0, 0, self.width, self.height)
                _frames[idx] = frame
            end
            local col = (frame.number-1) % _cols
            local row = math.floor((frame.number-1) / _cols)
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
            frames[idx] = frame
        end
        return frames
    end

    function self.clean()
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(_texture)
        if not texture then
            return
        end
        Log.i("Cleaning texture (%s)", _texture)
        for idx, frame in pairs(_frames) do
            cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(getFrameName(frame))
        end
        cc.SpriteFrameCache:getInstance():removeSpriteFramesFromTexture(texture)
        cc.Director:getInstance():getTextureCache():removeTextureForKey(_texture)
        --cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
    end

    SpriteSheet.register(_texture, self)

    return self
end
