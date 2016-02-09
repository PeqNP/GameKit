--
-- Wrapper for system and common API related features of the underlying
-- gaming framework.
--
-- @copyright (c) 2014 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

local Error = require("Error")
local Promise = require("Promise")

local shim = {}

function shim.GenerateShader(shader, vertex, frag)
    Log.i("Loading shader (%s)", shader)
    local prg = cc.GLProgram:createWithFilenames(
        shim.fullPathForFilename(string.format("%s.vsh", vertex))
      , shim.fullPathForFilename(string.format("%s.fsh", frag))
    )
    prg:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    prg:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    prg:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
    prg:link()
    prg:updateUniforms()
    cc.GLProgramCache:getInstance():addGLProgram(prg, shader)
end

-- Returns random point, within visible area, where a sprite can be placed.
function shim.GetRandomPoint(sprite)
    -- @fixme Ensure that the sprite is always in view. This code does not
    -- do that.
    local size = shim.GetVisibleSize()
    local xMin, xMax = 50, size.width - 50
    local yMin, yMax = BOTTOM_AD_HEIGHT + 50, size.height - 50
    local x = math.random(xMin, xMax)
    local y = math.random(yMin, yMax)
    return cc.p(x, y)
end

--
-- Returns a point which represents the position of a location.
--
-- For instance, if provided Location.TopLeft this will produce a point
-- that is near the top left of the screen.
--
-- This is generally used for rolling credits at the ending of a game.
--
function shim.GetPointForLocation(location, sprite, padding)
    local size = shim.GetVisibleSize()
    local x, y
    if location == Location.Random then
        location = math.random(Location.MIN, Location.MAX-1) -- -1 to remove 'Random'
    end
    if not padding then
        padding = 0
    end
    local bbox = sprite:getBoundingBox()
    local wpad = (bbox.width / 2) + padding -- Width padding
    local hpad = (bbox.height / 2) + padding -- height padding
    if location == Location.TopLeft then
        x = wpad
        y = size.height - hpad
    elseif location == Location.Top then
        x = size.width / 2
        y = size.height - hpad
    elseif location == Location.TopRight then
        x = size.width - wpad
        y = size.height - hpad
    elseif location == Location.Right then
        x = size.width - wpad
        y = size.height / 2
    elseif location == Location.BottomRight then
        x = size.width - wpad
        y = hpad + BOTTOM_AD_HEIGHT + BUTTON_PADDING
    elseif location == Location.Bottom then
        x = size.width / 2
        y = hpad + BOTTOM_AD_HEIGHT + BUTTON_PADDING
    elseif location == Location.BottomLeft then
        x = wpad
        y = hpad + BOTTOM_AD_HEIGHT + BUTTON_PADDING
    elseif location == Location.Left then
        x = wpad
        y = size.height / 2
    elseif location == Location.Center then
        x = size.width / 2
        y = (size.height / 2) + BOTTOM_AD_HEIGHT
    else
        Log.e("Invalid location (%s)", tostring(location))
    end
    return cc.p(x, y)
end

--
-- Returns respective position for a given heading. A heading
-- is a Location sans Center.
--
function shim.GetPointForHeading(heading)
    local size = shim.GetVisibleSize()
    local x, y
    if heading == Location.Random then
        -- Do not factor in Center or Random locations as they are
        -- not considered valid headings.
        heading = math.random(Location.MIN, Location.MAX-2)
    end
    if heading == Location.Top then
        x = size.width / 2
        y = size.height
    elseif heading == Location.TopRight then
        x = size.width
        y = size.height
    elseif heading == Location.Right then
        x = size.width
        y = size.height / 2
    elseif heading == Location.BottomRight then
        x = size.width
        y = 0
    elseif heading == Location.Bottom then
        x = size.width / 2
        y = 0
    elseif heading == Location.BottomLeft then
        x = 0
        y = 0
    elseif heading == Location.Left then
        x = 0
        y = size.height / 2
    elseif heading == Location.TopLeft then
        x = 0
        y = size.height
    else
        Log.e("Invalid heading (%s)", heading)
    end
    return cc.p(x, y)
end

-- Return the next position and angle given the target and current position of an actor.
function shim.GetNextPosition(pos, target, distance)
    local angle = math.atan2(target.y - pos.y, target.x - pos.x)
    local pos = cc.p(pos.x + (distance * math.cos(angle)), pos.y + (distance * math.sin(angle)))
    return pos
end

--
-- Get distance between two points.
--
-- @param cc.p loca current point
-- @param cc.p locb destination point
--
function shim.GetDistance(loca, locb)
    -- current position is considered point A. dest, point B
    local aDist = loca.x - locb.x
    local bDist = loca.y - locb.y
    local cDist = math.sqrt((aDist * aDist) + (bDist * bDist))
    return cDist
end

function shim.GetRenderedTexture(child)
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

function shim.FitImageInCenter(img)
    local size = shim.GetVisibleSize()
    local origin = shim.GetMidPoint()

    local contentSize = img:getContentSize()
    local x, y = size.width / contentSize.width, size.height / contentSize.height
    img:setScaleX(x)
    img:setScaleY(y)
    img:setPosition(origin.x, origin.y)
end

function shim.TakeScreenShot()
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

function shim.OpenURL(url)
    cc.Application:getInstance():openURL(url)
end

--
-- Seed random number generator and pop a few random numbers to ensure that the
-- numbers are random.
-- Reference: http://lua-users.org/wiki/MathLibraryTutorial
--
function shim.RandomizeSeed()
    math.randomseed(os.time())
    math.random(); math.random(); math.random();
end

-- ----- Director -----

function shim.Director()
    return cc.Director:getInstance()
end

local director = shim.Director()

function shim.GetRunningScene()
    return director:getRunningScene()
end

function shim.GetVisibleSize()
    return director:getVisibleSize()
end

function shim.GetOrigin()
    return director:getVisibleOrigin()
end

function shim.GetWinSizeInPixels()
    return director:getWinSizeInPixels()
end

-- ----- Actions ------

function shim.RunAction(action)
    return shim.GetRunningScene():runAction(action)
end

function shim.FadeTransition(node, delay)
    return cc.TransitionFade:create(delay, node)
end

function shim.TransitionScene(transition)
    return director:replaceScene(transition)
end

function shim.RunScene(scene)
    return director:runWithScene(scene)
end

-- ----- File Utilities -----

function shim.GetFullFilepath(path)
    return cc.FileUtils:getInstance():fullPathForFilename(path)
end

function shim.AddSearchPath(path)
    cc.FileUtils:getInstance():addSearchPath(path);
end

-- ----- Scheduler -----

--
-- Schedules a function callback to be called every tick.
--
-- @param fn - function to call
-- @param number priority - interal to call method in seconds. If 0, will be called every frame.
-- @param boolean paused - If yes, will not run until it is resumed.
--
-- @return number - ID of script registration
--
function shim.ScheduleFunc(fn, priority, paused)
    return director:getScheduler():scheduleScriptFunc(fn, priority, paused)
end

-- @todo Find pauseScheduleFunc

function shim.UnscheduleFunc(scheduleId)
    director:getScheduler():unscheduleScriptEntry(scheduleId)
end

function shim.GetMidPoint()
    local size = shim.GetVisibleSize()
    local origin = shim.GetOrigin()
    return cc.p(origin.x + (size.width / 2), origin.y + (size.height / 2))
end

--
-- Delay N seconds before executing call.
--
function shim.DelayCall(fn, delay)
    local sequence = shim.Sequence(shim.Delay(delay), shim.Call(fn))
    shim.RunAction(sequence)
end

-- ----- Objects ------

function shim.Layer()
    return cc.Layer:create()
end

function shim.Scene()
    return cc.Scene:create()
end

function shim.Sprite(...)
    return cc.Sprite:create(...)
end

function shim.SpriteButton(normal, selected, disabled, callback)
    local button = cc.MenuItemSprite:create(normal, selected, disabled)
    if callback then
        button:registerScriptTapHandler(callback)
    end
    return button
end

-- ----- Utility ------

-- Returns table{.x, .y} given (x, y)
shim.p = cc.p

function shim.p3(x, y, z)
    return {x=x, y=y, z=z}
end

function shim.GetTime()
    return gettime()
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

function shim.Sequence(...)
    return cc.Sequence:create(...)
end

function shim.Animate(anim)
    return cc.Animate:create(anim)
end

function shim.Animation(frames, dur)
    return cc.Animation:createWithSpriteFrames(frames, dur)
end

function shim.Call(fn)
    return cc.CallFunc:create(fn)
end

function shim.Delay(t)
    return cc.DelayTime:create(t)
end

function shim.EaseBackIn(act)
    return cc.EaseBackIn:create(act)
end

function shim.EaseBackInOut(act)
    return cc.EaseBackInOut:create(act)
end

function shim.EaseBackOut(act)
    return cc.EaseBackOut:create(act)
end

function shim.EaseInOut(act, dur)
    return cc.EaseInOut:create(act, dur)
end

function shim.EaseIn(act, dur)
    return cc.EaseIn:create(act, dur)
end

function shim.EaseOut(act, dur)
    return cc.EaseOut:create(act, dur)
end

function shim.FadeIn(t)
    return cc.FadeIn:create(t)
end

function shim.FadeOut(t)
    return cc.FadeOut:create(t)
end

function shim.FadeTo(t, flt)
    return cc.FadeTo:create(t, flt)
end

function shim.FadeEffectTo(sourceId, dur, dst, stop)
    return cc.FadeEffectTo:create(sourceId, dur, dst, stop)
end

function shim.MoveTo(dur, pos)
    return cc.MoveTo:create(dur, pos)
end

function shim.Repeat(anim, times)
    return cc.Repeat:create(anim, times)
end

function shim.RepeatForever(anim)
    return cc.RepeatForever:create(anim)
end

function shim.RotateTo(dur, angle)
    return cc.RotateTo:create(dur, angle)
end

function shim.ScaleTo(t, flt)
    return cc.ScaleTo:create(t, flt)
end

function shim.TintTo(t, flt1, flt2, flt3)
    return cc.TintTo:create(t, flt1, flt2, flt3)
end

function shim.TransitionFade(t, scene)
    return cc.TransitionFade:create(t, scene)
end

-- ----- Conversions -----

function shim.DegToRad(radians)
    return radians * 0.01745329252 -- PI / 180
end

function shim.RadToDeg(degrees)
    return degrees * 57.29577951 -- PI * 180
end

-- Button z-index
shim.Z_BUTTON = 42
-- Z-index for faded black background
shim.Z_SCENE_BG = 50

return shim
