
require "lang.Signal"

require "specs.Cocos2d"
require "specs.OpenGl"
require "specs.LuaClass"
require "specs.NetworkConstants"

cc.EventDispatcher = class()

function cc.EventDispatcher:addEventListenerWithSceneGraphPriority(handler, node)
end

cc.TransitionFade = class()

function cc.TransitionFade:create()
    return cc.TransitionFade()
end

cc.Scene = class()

function cc.Scene:create()
    return cc.Scene()
end

function cc.Scene:addChild(child)
end

function cc.Scene:runAction(action)
end

cc.Layer = class()

function cc.Layer:create()
    return cc.Layer()
end

function cc.Layer:addChild(child)
end

function cc.Layer:getEventDispatcher()
    return cc.EventDispatcher()
end

function cc.Layer:registerScriptHandler(fn)
end

--[[ This really belongs on a Node class. Layer and Sprite should subclass it. ]]--
function cc.Layer:scheduleUpdateWithPriorityLua(fn, rp)
end

function cc.Layer:runAction(action)

end

cc.Texture2D = class()

function cc.Texture2D:getName()
    return "name"
end

function cc.Texture2D:setTexParameters(params)
end

cc.Sprite = class()

function cc.Sprite:create()
    return cc.Sprite()
end

function cc.Sprite:createWithSpriteFrame(frame)
    return cc.Sprite()
end

function cc.Sprite:runAction(action)
end

function cc.Sprite:stopAllActions()
end

function cc.Sprite:setSpriteFrame(frame)
    self.frame = frame
end

function cc.Sprite:getScale()
    return 100
end

function cc.Sprite:getBoundingBox()
    return cc.rect(0,0,100,100)
end

function cc.Sprite:addChild(child)
end

function cc.Sprite:getTexture()
    return cc.Texture2D()
end

function cc.Sprite:setTag(tag)
end

function cc.Sprite:getContentSize()
    return {width=100, height=100, note="cc.Sprite:getContentSize()"}
end

function cc.Sprite:setScale(scale)
end

function cc.Sprite:setScaleX(scaleX)
end

function cc.Sprite:setScaleY(scaleY)
end

function cc.Sprite:setGLProgram(prog)
end

function cc.Sprite:setGlobalZOrder(z)
end

function cc.Sprite:setPosition(pos)
    self.pos = pos
end

function cc.Sprite:getPosition()
    return self.pos and self.pos or cc.p(1,1)
end

function cc.Sprite:scheduleUpdateWithPriorityLua(fn, rp)
end

function cc.Sprite:unschedule(fn)
end

cc.TextureCache = class()

function cc.TextureCache:addImage(img)
    return cc.Texture2D()
end

function cc.TextureCache:getTextureForKey(key)
    return key
end

cc.Scheduler = class()

function cc.Scheduler:scheduleScriptFunc(fn, priority, pause)
end

function cc.Scheduler:unscheduleScriptEntry(scheduledId)
end

cc.Director = class()

function cc.Director:getInstance()
    return cc.Director()
end

function cc.Director:getVisibleSize()
    return {width=100, height=100}
end

function cc.Director:getVisibleOrigin()
    return {x=0, y=0}
end

function cc.Director:getTextureCache()
    return cc.TextureCache()
end

function cc.Director:getScheduler()
    return cc.Scheduler()
end

function cc.Director:getRunningScene()
    return cc.Scene()
end

function cc.Director:replaceScene(transition)
    return cc.Scene()
end

function cc.Director:runWithScene(scene)
end

function cc.Director:isPaused()
end

function cc.Director:pause()
end

function cc.Director:resume()
end

function cc.Director:startAnimation()
end

function cc.Director:stopAnimation()
end

cc.TMXTiledMap = class()

function cc.TMXTiledMap:create()
    return cc.TMXTiledMap()
end

function cc.TMXTiledMap:getContentSize()
    return {width=100, height=100}
end

function cc.TMXTiledMap:setPosition(pos)
end

cc.GLProgram = class()

function cc.GLProgram:createWithFilenames(fileNames)
    return cc.GLProgram()
end

function cc.GLProgram:link()
end

function cc.GLProgram:use()
end

function cc.GLProgram:updateUniforms()
end

function cc.GLProgram:setUniformsForBuiltins()
end

function cc.GLProgram:getProgram()
end

function cc.GLProgram:setUniformLocationI32(texId, texNum)
end

cc.FileUtils = class()

function cc.FileUtils:getInstance()
    return cc.FileUtils()
end

function cc.FileUtils:fullPathForFilename(filename)
    -- Add 'Coco2d-x' to indicate that this is a stubbed filepath that used the FileUtils method
    return "/Cocos2d-x/" .. filename
end

cc.GLProgramCache = class()

function cc.GLProgramCache:getInstance()
    return cc.GLProgramCache()
end

function cc.GLProgramCache:addGLProgram(prog)
end

cc.GLProgramState = class()

function cc.GLProgramState:getOrCreateWithGLProgram(prog)
    return cc.GLProgramState()
end

function cc.GLProgramState:setUniformFloat(uniform, flt)
end

cc.EventListenerTouchOneByOne = class()

function cc.EventListenerTouchOneByOne:create()
    return cc.EventListenerTouchOneByOne()
end

function cc.EventListenerTouchOneByOne:registerScriptHandler(fn, event)
end

cc.Handler = enum(1
  , 'EVENT_TOUCH_BEGAN'
  , 'EVENT_TOUCH_MOVED'
  , 'EVENT_TOUCH_ENDED'
)

cc.SpriteFrame = class()

function cc.SpriteFrame:getOriginalSize()
    return {width=100, height=100, note="cc.SpriteFrame:getOriginalSize()"}
end

cc.SpriteFrameCache = class()

local instance__spriteFrameCache
function cc.SpriteFrameCache:getInstance()
    if not instance__spriteFrameCache then
        instance__spriteFrameCache = cc.SpriteFrameCache()
    end
    return instance__spriteFrameCache
end

function cc.SpriteFrameCache:getSpriteFrame()
    return cc.SpriteFrame()
end

function cc.SpriteFrameCache:addSpriteFrames(plist)
end

function cc.SpriteFrameCache:removeSpriteFrames(plist)
end

cc.DelayTime = class()

function cc.DelayTime:create()
    return cc.DelayTime()
end

cc.CallFunc = class(function (self, fn)
    self.fn = fn
end)

function cc.CallFunc:call()
    self.fn()
end

-- Cocos2d-x

function cc.CallFunc:create(fn)
    return cc.CallFunc(fn)
end

cc.Sequence = class(function (self, ...)
    self.actions = {...}
end)

function cc.Sequence:getActions()
    return self.actions
end

function cc.Sequence:executeLastCall()
    local lastCall
    for k, v in ipairs(self.actions) do
        if v.is_a and v:is_a(cc.CallFunc) then
            lastCall = v
        end
    end
    if lastCall then
        lastCall:call()
    end
end

function cc.Sequence:executeCalls()
    for k, v in ipairs(self.actions) do
        if v.is_a and v:is_a(cc.CallFunc) then
            v:call()
        end
    end
end

-- Cocos2d-x

function cc.Sequence:create(...)
    return cc.Sequence(...)
end

cc.MoveTo = class()

function cc.MoveTo:create()
    return cc.MoveTo()
end

cc.FadeEffectTo = class()

function cc.FadeEffectTo:create()
    return cc.FadeEffectTo()
end

cc.SimpleAudioEngine = class()

local SimpleAudioEngineInstance
function cc.SimpleAudioEngine:getInstance()
    if not SimpleAudioEngineInstance then
        SimpleAudioEngineInstance = cc.SimpleAudioEngine()
    end
    return SimpleAudioEngineInstance
end

function cc.SimpleAudioEngine:getMusicVolume()
    return 1
end

function cc.SimpleAudioEngine:preloadEffect(path)
end

function cc.SimpleAudioEngine:playEffect(path, loop, pitch, pan, gain)
    return -1
end

function cc.SimpleAudioEngine:unloadEffect(path)
end

function cc.SimpleAudioEngine:getEffectLengthInSeconds(path)
    return 0
end

function cc.SimpleAudioEngine:setEffectGain(sourceId, gain)
end

function cc.SimpleAudioEngine:setEffectPan(sourceId, pan)
end

function cc.SimpleAudioEngine:getEffectGain(sourceId)
    return 1
end

function cc.SimpleAudioEngine:getEffectPan(sourceId)
    return 0
end

function cc.SimpleAudioEngine:setMusicVolume(vol)
end

function cc.SimpleAudioEngine:pauseMusic(vol)
end

function cc.SimpleAudioEngine:resumeMusic(vol)
end

cc.XMLHttpRequest = class(function(self)
    self.fn = false
    self.status = 0
    self.statusText = "Status Text"
    self.responseType = 0
    self.response = ""
end)

function cc.XMLHttpRequest:new()
    return cc.XMLHttpRequest()
end

function cc.XMLHttpRequest:registerScriptHandler(fn)
    self.fn = fn
end

function cc.XMLHttpRequest:open(reqtype, url, async)
end

function cc.XMLHttpRequest:send()
end

cc.MenuItemSprite = class(function (self)
    self.fn = false
end)

function cc.MenuItemSprite:create()
    return cc.MenuItemSprite()
end

function cc.MenuItemSprite:registerScriptTapHandler(f)
    self.fn = f
end

function cc.MenuItemSprite:activate()
    if self.fn then
        self.fn()
    else
        Log.s("MenuItemSprite (%s) does not have a registered script handler!")
    end
end

function cc.MenuItemSprite:setOpacity(opacity)
end

function cc.MenuItemSprite:setVisible(visible)
end

function cc.MenuItemSprite:setPosition(point)
end

function cc.MenuItemSprite:getBoundingBox()
    return cc.rect(0,0,10,10)
end

cc.Application = class()

local instance__Application
function cc.Application:getInstance()
    if not instance__Application then
        instance__Application = cc.Application()
    end
    return instance__Application
end

function cc.Application:openURL(url)
end

-- Rather than recreate these, just bring in the Cocos2d-x util scripts.
function cc.p(x, y)
    return {x=x, y=y}
end

cc.Menu = class()

function cc.Menu:create()
    return cc.Menu()
end

function cc.Menu:setPosition(x, y)
end

function cc.Menu:addChild(child)
end
