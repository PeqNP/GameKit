--[[
  Convenience wrappers for many Cocos2d-x methods.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

require "Logger"

local Error = require("Error")
local Promise = require("Promise")
local Music = require("Music")

cu = {}

function cu.GenerateShader(shader, vertex, frag)
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
function cu.GetRandomPoint(sprite)
    -- @fixme Ensure that the sprite is always in view. This code does not
    -- do that.
    local size = cu.GetVisibleSize()
    local xMin, xMax = 50, size.width - 50
    local yMin, yMax = BOTTOM_AD_HEIGHT + 50, size.height - 50
    local x = math.random(xMin, xMax)
    local y = math.random(yMin, yMax)
    return cc.p(x, y)
end

--[[ Returns a point which represents the position of a location.

  For instance, if provided Location.TopLeft this will produce a point
  that is near the top left of the screen.

  This is generally used for rolling credits at the ending of a game.

--]]
function cu.GetPointForLocation(location, sprite, padding)
    local size = cu.GetVisibleSize()
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
function cu.GetPointForHeading(heading)
    local size = cu.GetVisibleSize()
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

--[[ Return the next position and angle given the target and current position
     of an actor. ]]--
function cu.GetNextPosition(pos, target, distance)
    local angle = math.atan2(target.y - pos.y, target.x - pos.x)
    local pos = cc.p(pos.x + (distance * math.cos(angle)), pos.y + (distance * math.sin(angle)))
    return pos
end

--[[
  Get distance between two points.

  @param cc.p loca current point
  @param cc.p locb destination point

--]]
function cu.GetDistance(loca, locb)
    -- current position is considered point A. dest, point B
    local aDist = loca.x - locb.x
    local bDist = loca.y - locb.y
    local cDist = math.sqrt((aDist * aDist) + (bDist * bDist))
    return cDist
end

function cu.GetRenderedTexture(child)
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

function cu.FitImageInCenter(img)
    local size = cu.GetVisibleSize()
    local origin = cu.GetMidPoint()

    local contentSize = img:getContentSize()
    local x, y = size.width / contentSize.width, size.height / contentSize.height
    img:setScaleX(x)
    img:setScaleY(y)
    img:setPosition(origin.x, origin.y)
end

function cu.TakeScreenShot()
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

--
-- Seed random number generator and pop a few random numbers to ensure that the
-- numbers are random.
-- Reference: http://lua-users.org/wiki/MathLibraryTutorial
--
function cu.RandomizeSeed()
    math.randomseed(os.time())
    math.random(); math.random(); math.random();
end

-- ----- Director -----

function cu.Director()
    return cc.Director:getInstance()
end

local director = cu.Director()

function cu.GetRunningScene()
    return director:getRunningScene()
end

function cu.IsPaused()
    return director:isPaused()
end

function cu.Pause()
    if not cu.isPaused() then
        director:pause()
        director:stopAnimation()
        Music.singleton.pause()
    end
end

function cu.Resume()
    if cu.isPaused() then
        director:startAnimation()
        Music.singleton.resume()
        director:resume()
    end
end

function cu.GetVisibleSize()
    return director:getVisibleSize()
end

function cu.GetOrigin()
    return director:getVisibleOrigin()
end

function cu.GetWinSizeInPixels()
    return director:getWinSizeInPixels()
end

-- ----- Actions ------

function cu.RunAction(action)
    return cu.RunningScene():runAction(action)
end

function cu.FadeTransition(node, delay)
    return cc.TransitionFade:create(delay, node)
end

function cu.TransitionScene(transition)
    return director:replaceScene(transition)
end

function cu.RunScene(scene)
    return director:runWithScene(scene)
end

-- ----- File Utilities -----

function cu.GetFullFilepath(path)
    return cc.FileUtils:getInstance():fullPathForFilename(path)
end

function cu.AddSearchPath(path)
    cc.FileUtils:getInstance():addSearchPath(path);
end

-- ----- Scheduler -----

--[[ Schedules a function callback to be called every tick.

  @param fn - function to call
  @param number priority - interal to call method in seconds. If 0, will be called every frame.
  @param boolean paused - If yes, will not run until it is resumed.

  @return number - ID of script registration

--]]
function cu.ScheduleFunc(fn, priority, paused)
    return director:getScheduler():scheduleScriptFunc(fn, priority, paused)
end

-- @todo Find pauseScheduleFunc

function cu.UnscheduleFunc(scheduleId)
    director:getScheduler():unscheduleScriptEntry(scheduleId)
end

function cu.GetMidPoint()
    local size = cu.GetVisibleSize()
    local origin = cu.GetOrigin()
    return cc.p(origin.x + (size.width / 2), origin.y + (size.height / 2))
end

--
-- Delay N seconds before executing call.
--
function cu.DelayCall(fn, delay)
    local sequence = cu.Sequence(cu.Delay(delay), cu.Call(fn))
    cu.runAction(sequence)
end

-- ----- Objects ------

function cu.Layer()
    return cc.Layer:create()
end

function cu.Scene()
    return cc.Scene:create()
end

function cu.Sprite(...)
    return cc.Sprite:create(...)
end

function cu.SpriteButton(...)
    return cc.MenuItemSprite:create(...)
end

-- ----- Utility ------

-- Returns table{.x, .y} given (x, y)
cu.p = cc.p

function cu.p3(x, y, z)
    return {x=x, y=y, z=z}
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
    return cc.FadeEffectTo:create(sourceId, dur, dst, stop)
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

function cu.DegToRad(radians)
    return radians * 0.01745329252 -- PI / 180
end

function cu.RadToDeg(degrees)
    return degrees * 57.29577951 -- PI * 180
end

-- Button z-index
cu.Z_BUTTON = 42
-- Z-index for faded black background
cu.Z_SCENE_BG = 50

-- @deprecated
cu.runAction = cu.RunAction
cu.scheduleFunc = cu.ScheduleFunc
cu.unscheduleFunc = cu.UnscheduleFunc
cu.isPaused = cu.IsPaused
cu.pause = cu.Pause
cu.resume = cu.Resume
cu.fullPathForFilename = cu.GetFullFilepath
cu.getFullFilepath = cu.GetFullFilepath
cu.addSearchPath = cu.AddSearchPath
cu.getVisibleSize = cu.GetVisibleSize
cu.getOrigin = cu.GetOrigin
cu.getWinSizeInPixels = cu.GetWinSizeInPixels
cu.generateShader = cu.GenerateShader
cu.getRandomPoint = cu.GetRandomPoint
cu.getPointForLocation = cu.GetPointForLocation
cu.getPointForHeading = cu.GetPointForHeading
cu.getNextPosition = cu.GetNextPosition
cu.getDistance = cu.GetDistance
cu.getRenderedTexture = cu.GetRenderedTexture
cu.fitImageInCenter = cu.FitImageInCenter
cu.takeScreenShot = cu.TakeScreenShot
cu.getMidPoint = cu.GetMidPoint
cu.delayCall = cu.DelayCall
cu.degToRad = cu.DegToRad
cu.radToDeg = cu.RadToDeg

return cu
