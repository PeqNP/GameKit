require "socket.core"

local shim = require("shim.Main")

local Game = Class()
Game.implements("GameProtocol")

-- Add any search paths your game may need access to
-- shim.addSearchPath("res/subdirectory")

function Game.new(self)
    local writablePath
    local adManager
    local appManager
    local iap
    local royalAdVendor
    local socialManager
    local scheduleId

    -- ----- Helper Functions -----

    local function getPlatform()
        if device.platform == "android" then
            return "android"
        elseif device.platform == "ios" then
            return "ios"
        else
            return "unknown"
        end
    end

    local function getEnvironmentUrl()
        return "http://www.example.com"
    end

    local function getImageVariant()
        -- Remove the 'android' condition if game supports hd and xhd on Android.
        if device.platform == "android" or display.contentScaleFactor == 1.0 then
            return "hd"
        end
        return "xhd"
    end

    -- ----- Royal Ad network -----

    local function initRoyalAdNetwork()
        local AdConfig = require("royal.AdConfig")
        local Client = require("royal.Client")
        local AdVendor require("royal.AdVendor")

        Log.i("Initializing the Royal Ad Network...")
        AdConfig.singleton.setBasePath(writablePath)
        AdConfig.singleton.setImageVariant(getImageVariant())
        local network = Client(getEnvironmentUrl(), 80, "/ad/com.upstartillustration.blobfish."..getPlatform().."/", {1})
        network.loadFromCache()
        local promise = network.downloadAds()
        promise.done(function(success)
            Log.i("Downloaded manifest (%s)", tostring(success))

            if not success then
                -- @todo This should be configurable.
                -- @todo This should stop after a certain number of times. It should increase the amount of time
                -- before the next retry.
                -- @fixme It's just too risky to include this in.
                --Log.i("Failed to download ads... restarting in 120.0s")
                --level.layer:runAction(shim.Sequence(shim.Delay(120.0), shim.Call(initRoyalAdNetwork)))
                return
            end

            Log.i("Successfully downloaded manifest!")

            local function matcher()
                return true
            end

            royalAdVendor = AdVendor(network.getManifest(), matcher)
        end)
        promise.fail(function()
            Log.e("Failed to download manifest!")
        end)
    end

    -- ----- App Manager -----

    function self.appDidBecomeActive()
        Log.i("Game:appWillBecomeInactive() - App did become active")
    end

    function self.appWillBecomeInactive()
        Log.i("Game:appWillBecomeInactive() - App did background")
    end

    function initAppManager()
        local notifications = appManager.getNotifications()
        if notifications > 0 then
            Log.i("User opened app w/ notification")
        end
        -- Setup a notification
        appManager.setupNotification("Come back and get a reward!", 86400)
        appManager.setDelegate(self)
    end

    -- ----- AdManager -----

    function getAdManager()
        return adManager
    end

    local function showBannerAd()
        Log.i("Showing banner ad...")
        local promise = adManager.showBannerAd()
        if not promise then
            Log.e("Failed to show banner! %s", adManager.getError())
            return
        end
        promise.done(function()
            Log.d("Successfully displayed banner ad")
        end)
        promise.fail(function()
            Log.e("Failed to show the banner ad!")
            -- @todo Try again later?
        end)
    end

    local function initAdManager()
        -- This is asynchronous. It's possible the IAP was purchased before the ad
        -- config was retrieved from the server.
        local promise = adServer.fetchConfig()
        promise.done(function(_adManager)
            adManager = _adManager
        end)
        promise.fail(function(_error)
            Log.e(tostring(_error))

            -- Set default configuration if we are not able to fetch the confir from the server.
            -- This will show AdColony videos and AdMob interstitials.
            local MediationAdConfig = require("mediation.MediationAdConfig")
            local MediationAdFactory = require("mediation.MediationAdFactory")

            local defaultAdFactory = MediationAdFactory({
                MediationAdConfig(AdNetwork.AdColony, AdType.Video, AdImpressionType.Regular, 100, 20, 35)
              , MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 100, 5, 15)
            })
            adManager = adServer.getAdManager(defaultAdFactory)
        end)
        promise.always(function()
            showBannerAd()
        end)
    end

    -- ----- IAP Manager -----

    function disableAds()
        -- @todo
    end

    function getIAPManager()
        return iap
    end

    local function initIAP()
        local promise = iap.query()
        promise.done(function(store)
            local products = store.getProducts()
            Log.i("Successfully queried (%s) IAP products", #products)
        end)
        promise.fail(function()
            Log.e("Failed to query for IAP products!")
            -- @todo Re-query after a certain period of time? Or maybe when there is available IAP
            -- but a previous query failed?
        end)
    end

    -- ----- App Configuration -----

    local isAppConfigured = false
    local function configureApp()
        if isAppConfigured then
            return
        end

        initAdManager()
        initRoyalAdNetwork()
        initIAP()
        initAppManager()

        isAppConfigured = true
    end

    -- Starts the scene using config. This can also be used to load the next level.
    function self.start()
        if scheduleId then
            Log.d("Unscheduling main tick w/ ID (%s)", scheduleId)
            shim.UnscheduleFunc(scheduleId)
            scheduleId = false
        end

        -- Main scene creation. Add a layer to this scene.
        local scene = shim.Scene()

        -- Fade into the next scene.
        if shim.GetRunningScene() then
            shim.TransitionScene(shim.FadeTransition(scene, 4.0))
        else
            shim.RunScene(scene)
        end

        -- Main game run loop
        local function tick()
            -- @note Execute any method that must be done every tick.
        end
        scheduleId = shim.ScheduleFunc(tick, 0, false)

        -- Run some initialization routines to prevent race-conditions (like app
        -- notifications, etc.) by running them one second after the game has
        -- began running.
        local function boot()
            Log.i("Booting game...")
            -- configureApp()
        end
        shim.RunAction(shim.Sequence(shim.Delay(1.0), shim.Call(boot)))
    end

    function self.stop()
    end

    function self.restart()
        self.start()
    end

    function self.init(_writablePath, _appManager, _adServer, _iap, _socialManager)
        writablePath = _writablePath
        appManager = _appManager
        adServer = _adServer
        iap = _iap
        socialManager = _socialManager

        -- local saveFile = writablePath .. "game.save"

        shim.RandomizeSeed()
    end
end

return Game
