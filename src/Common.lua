--[[
  Convenience wrappers for many Cocos2d-x methods.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

require "Error"
require "Logger"
require "Promise"

cu = {}

function cu.fullPathForFilename(path)
    return cc.FileUtils:getInstance():fullPathForFilename(path)
end

function cu.generateShader(shader, vertex, frag)
    Log.i("Loading shader (%s)", shader)
    local prg = cc.GLProgram:createWithFilenames(
        cu.fullPathForFilename(string.format("%s.vsh", vertex))
      , cu.fullPathForFilename(string.format("%s.fsh", frag))
    )
    prg:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    prg:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    prg:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
    prg:link()
    prg:updateUniforms()
    cc.GLProgramCache:getInstance():addGLProgram(prg, shader)
end

--[[ Returns random point, within visible area, where a sprite can be
     placed. ]]--
function cu.getRandomPoint(sprite)
    -- @fixme Ensure that the sprite is always in view. This code does not
    -- do that.
    local size = getVisibleSize()
    local xMin, xMax = 50, size.width - 50
    local yMin, yMax = BOTTOM_AD_HEIGHT + 50, size.height - 50
    local x = math.random(xMin, xMax)
    local y = math.random(yMin, yMax)
    return cc.p(x, y)
end

function cu.getVisibleSize()
    return cc.Director:getInstance():getVisibleSize()
end

function cu.getOrigin()
    return cc.Director:getInstance():getVisibleOrigin()
end

function cu.scheduleScriptEntry(fn, priority, paused)
    return cc.Director:getInstance():getScheduler():scheduleScriptFunc(fn, priority, paused)
end

function cu.unscheduleScriptEntry(scheduleId)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
end

function cu.preloadMusic(path)
    cc.SimpleAudioEngine:getIntance():preloadBackgroundMusic(path)
end

function cu.playMusic(path, loop)
    cc.SimpleAudioEngine:getInstance():playBackgroundMusic(path, loop)
end

function cu.stopMusic(release)
    cc.SimpleAudioEngine:getInstance():stopBackgroundMusic(release)
end

function cu.setMusicVolume(to)
    cc.SimpleAudioEngine:getInstance():setMusicVolume(to)
end

function cu.preloadEffect(path)
    cc.SimpleAudioEngine:getInstance():preloadEffect(path)
end

function cu.playEffect(path, loop, pitch, pan, gain)
    cc.SimpleAudioEngine:getInstance():playEffect(path, loop, pitch, pan, gain)
end

function cu.unloadEffect(path)
    cc.SimpleAudioEngine:getInstance():preloadEffect(path)
end

function cu.getMidPoint()
    local size = cu.getVisibleSize()
    local origin = cu.getOrigin()
    return cc.p(origin.x + (size.width / 2), origin.y + (size.height / 2))
end

--[[ Returns a point which represents the position of a heading.

  For instance, if provided Heading.TopLeft this will produce a point
  that is near the top left of the screen.

  This is generally used for rolling credits at the ending of a game.

--]]
function cu.getPointForPosition(position, sprite, padding)
    local size = getVisibleSize()
    local x, y
    if position == Heading.Random then
        position = math.random(Heading.MIN, Heading.MAX-1) -- -1 to remove 'Random'
    end
    if not padding then
        padding = 0
    end
    local bbox = sprite:getBoundingBox()
    local wpad = (bbox.width / 2) + padding -- Width padding
    local hpad = (bbox.height / 2) + padding -- height padding
    if position == Heading.TopLeft then
        x = wpad
        y = size.height - hpad
    elseif position == Heading.Top then
        x = size.width / 2
        y = size.height - hpad
    elseif position == Heading.TopRight then
        x = size.width - wpad
        y = size.height - hpad
    elseif position == Heading.Right then
        x = size.width - wpad
        y = size.height / 2
    elseif position == Heading.BottomRight then
        x = size.width - wpad
        y = hpad + BOTTOM_AD_HEIGHT + BUTTON_PADDING
    elseif position == Heading.Bottom then
        x = size.width / 2
        y = hpad + BOTTOM_AD_HEIGHT + BUTTON_PADDING
    elseif position == Heading.BottomLeft then
        x = wpad
        y = hpad + BOTTOM_AD_HEIGHT + BUTTON_PADDING
    elseif position == Heading.Left then
        x = wpad
        y = size.height / 2
    elseif position == Heading.Center then
        x = size.width / 2
        y = (size.height / 2) + BOTTOM_AD_HEIGHT
    else
        Log.e("Invalid position (%s)", tostring(position))
    end
    return cc.p(x, y)
end

--[[ Return the location on the screen given a heading. ]]--
function cu.getHeadingPosition(heading)
    local size = getVisibleSize()
    local x, y
    if heading == Heading.Random then
        heading = math.random(Heading.MIN, Heading.MAX-1)
    end
    if heading == Heading.Top then
        x = size.width / 2
        y = size.height
    elseif heading == Heading.TopRight then
        x = size.width
        y = size.height
    elseif heading == Heading.Right then
        x = size.width
        y = size.height / 2
    elseif heading == Heading.BottomRight then
        x = size.width
        y = 0
    elseif heading == Heading.Bottom then
        x = size.width / 2
        y = 0
    elseif heading == Heading.BottomLeft then
        x = 0
        y = 0
    elseif heading == Heading.Left then
        x = 0
        y = size.height / 2
    elseif heading == Heading.TopLeft then
        x = 0
        y = size.height
    else
        Log.e("Invalid heading (%s)", heading)
    end
    return cc.p(x, y)
end

--[[ Return the next position and angle given the target and current position
     of an actor. ]]--
function cu.getNextPosition(pos, target, distance)
    local angle = math.atan2(target.y - pos.y, target.x - pos.x)
    local pos = cc.p(pos.x + (distance * math.cos(angle)), pos.y + (distance * math.sin(angle)))
    return pos
end

--[[
  Get distance between two points.

  @param cc.p loca current point
  @param cc.p locb destination point

--]]
function cu.getDistance(loca, locb)
    -- current position is considered point A. dest, point B
    local aDist = loca.x - locb.x
    local bDist = loca.y - locb.y
    local cDist = math.sqrt((aDist * aDist) + (bDist * bDist))
    return cDist
end

function cu.getRenderedTexture(child)
    local bbox = child:getBoundingBox()
    child:setPosition(bbox.width/2, bbox.height/2)
    local size = child:getContentSize()
    local texture = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
    texture:begin()
    texture:addChild(child)
    child:visit()
    texture:endToLua()
    local sprite = cc.Sprite:createWithTexture(texture:getSprite():getTexture())
    sprite:setFlippedY(true)
    return sprite
end

function cu.takeScreenShot()
    local promise = Promise()
    local path = cc.FileUtils:getInstance():getWritablePath() .. "screen.png"
    cc.utils:captureScreen(function(succeed, outputFile)
        if succeed then
            Log.i("Screenshot saved at (%s)", outputFile)
            promise.resolve(outputFile)
            return
        end
        promise.reject(Error("Failed to take screen shot at (%s)", outputFile))
    end, path)
    return promise
end

-- --------------------
-- ----- Objects ------

function cu.Director()
    return cc.Director:getInstance()
end

function cu.RunningScene()
    return cc.Director:getInstance():getRunningScene()
end

function cu.Layer()
    return cc.Layer:create()
end

function cu.Scene()
    return cc.Scene:create()
end

function SimpleAudioEngine()
    return cc.SimpleAudioEngine:getInstance()
end

function cu.Sprite(...)
    return cc.Sprite:create(...)
end

-- --------------------
-- ----- Utility ------

--[[ Convert Cocos2d-x getPosition to Point. ]]--
function cu.p(node)
    return cc.p(node:getPosition())
end

function cu.p3(x, y, z)
    return {x=x, y=y, z=z}
end

function cu.runAction(action)
    cu.RunningScene():runAction(action)
end

-- --------------------
-- ----- Events -------

--[[
  Cocos2dx Key:

   Var | Description
  -----+--------------------
   t   | time/duration
   flt | float
   fn  | function call back

--]]

-- @fixme needs testing
function cu.Sequence(...)
    return cc.Sequence:create(...)
end

function cu.Animate(anim)
    return cc.Animate:create(anim)
end

function cu.Animation(frames, dur)
    return cc.Animation:createWithSpriteFrames(frames, dur)
end

function cu.Call(fn)
    return cc.CallFunc:create(fn)
end

function cu.Delay(t)
    return cc.DelayTime:create(t)
end

function cu.EaseBackIn(act)
    return cc.EaseBackIn:create(act)
end

function cu.EaseBackInOut(act)
    return cc.EaseBackInOut:create(act)
end

function cu.EaseBackOut(act)
    return cc.EaseBackOut:create(act)
end

function cu.EaseInOut(act, dur)
    return cc.EaseInOut:create(act, dur)
end

function cu.EaseIn(act, dur)
    return cc.EaseIn:create(act, dur)
end

function cu.EaseOut(act, dur)
    return cc.EaseOut:create(act, dur)
end

function cu.FadeIn(t)
    return cc.FadeIn:create(t)
end

function cu.FadeOut(t)
    return cc.FadeOut:create(t)
end

function cu.FadeTo(t, flt)
    return cc.FadeTo:create(t, flt)
end

function cu.FadeEffectTo(sourceId, dur, dst, stop)
    return cc.FadeEffectTo:create(sourcIde, dur, dst, stop)
end

function cu.MoveTo(dur, pos)
    return cc.MoveTo:create(dur, pos)
end

function cu.Repeat(anim, times)
    return cc.Repeat:create(anim, times)
end

function cu.RepeatForever(anim)
    return cc.RepeatForever:create(anim)
end

function cu.RotateTo(dur, angle)
    return cc.RotateTo:create(dur, angle)
end

function cu.ScaleTo(t, flt)
    return cc.ScaleTo:create(t, flt)
end

function cu.TintTo(t, flt1, flt2, flt3)
    return cc.TintTo:create(t, flt1, flt2, flt3)
end

function cu.TransitionFade(t, scene)
    return cc.TransitionFade:create(t, scene)
end

--[[ Conversions. ]]--

function cu.DegreesToRadians(radians)
    return radians * 0.01745329252 -- PI / 180
end

function cu.RadiansToDegrees(degrees)
    return degrees * 57.29577951 -- PI * 180
end

-- Button z-index
cu.Z_BUTTON = 42
-- Z-index for faded black background
cu.Z_SCENE_BG = 50

return cu
