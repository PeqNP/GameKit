require "Cocos2d"
require "Cocos2dConstants"
require "socket.core"

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- Avoid memory leaks
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    --[[ Cocos2d-x has a wrapper for the AudioEngine already... Like the 
         other helper scripts, this one isn't included. It makes NO sense.
    if AudioEngine then
        print("-----> AudioEngine!!!!")
    end
    --]]

    -- Add our source and resource directories to the search paths.
	cc.FileUtils:getInstance():addSearchResolutionsOrder("src");
	cc.FileUtils:getInstance():addSearchResolutionsOrder("res");
	cc.FileUtils:getInstance():addSearchResolutionsOrder("res/shaders");
	cc.FileUtils:getInstance():addSearchResolutionsOrder("res/fx");

    -- OpenGL constants are not available with later versions. No idea why!
    -- Also, manual/cocos2d/LuaOpengl.cpp expose some OpenGL functions.
    require "OpenglConstants"
    -- print("gl.getSupportedExtensions", gl.getSupportedExtensions)

    -- ----------------------------------------

    require "src.lang.Signal"

    require "Common"
    require "Constants"
    require "Logger"

    require "IPC"

    require "V4CController"
    Singleton(V4CController)

    --Log.i("gl.maxTextureSize: %s", cc.Configuration:getInstance():getMaxTextureSize());

    require "src.game.Config"
    Singleton(Config, cc.FileUtils:getInstance():getWritablePath())

    Log.i("saveFile: %s", Config.singleton.saveFile)

    require "src.game.SaveState"
    Singleton(SaveState, Config.singleton.saveFile)
    SaveState.singleton.load()

    if SaveState.singleton.disableAds == 1 then
        require "AdFree"
    end

    --[[ Reset. Do this when testing is complete. Easier than uninstalling.
    SaveState.singleton.reset()
    SaveState.singleton.save()
    --]]

    --[[ Testing Levels ]]--
	--cc.FileUtils:getInstance():addSearchResolutionsOrder("src/tests");

    -- ----------------------------------------
    -- ----- Platform Detection ---------------
    
    --[[
      Available platforms:
        cc.PLATFORM_OS_IPHONE
        cc.PLATFORM_OS_IPAD
        cc.PLATFORM_OS_ANDROID
        cc.PLATFORM_OS_WINDOWS 
        cc.PLATFORM_OS_MAC 

    --]]
    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()

    -- Working on iPhone. Use different background. Because there is no
    -- way to determine the number of actual of pixels being used on the
    -- device I can't determine which background to use.
    if cc.PLATFORM_OS_IPAD ~= targetPlatform then
        Log.i("Platform: iPhone")
    else
        Log.i("Platform: iPad")
    end
 
    -- ----- Generate Shaders -----------------
    
    require "Shaders"

    for shader, parts in pairs(Shaders) do
        cu.generateShader(shader, parts[1], parts[2])
    end

    -- ----- Load FX --------------------------

    require "FX"

    -- Preload effects.
    for id, val in pairs(FX) do
        cc.SimpleAudioEngine:getInstance():preloadEffect(val)
    end
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(FX_MAX_VOL)

    --[[
      Seed random number generator and pop a few random numbers to ensure that the
      numbers are random.

      Reference: http://lua-users.org/wiki/MathLibraryTutorial

    --]]
    math.randomseed(os.time())
    math.random(); math.random(); math.random();

    -- ----- Load Sub-systems -----------------
    
    require "Music"
    Singleton(Music)

    require "Sound"
    Singleton(Sound)

    -- ----- Game Bootloader ------------------

    require "src.game.Controller"
    Singleton(Controller)

    -- @todo Preload menu, dialog, progress bar assets here.
    if SaveState.singleton.restartGame == 1 then
        Controller.singleton.restart()
    else
        Controller.singleton.start()
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
