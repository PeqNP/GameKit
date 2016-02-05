require "socket.core"

local shim = require("shim.System")

local Game = Class()
Game.implements("GameProtocol")

-- Add any search paths your game may need access to
-- shim.addSearchPath("res/subdirectory")

function Game.new(self)
    local writablePath
    local adManager
    local appManager
    local iap
    local royalClient
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

    local adVendor
    function getRoyalAdVendor()
        return adVendor
    end

    local function initRoyalAdNetwork()
        local promise = royalClient.fetchConfig()
        promise.done(function(manifest)
            local AdStylizer = require("royal.AdStylizer")
            local AdVendor = require("royal.AdVendor")
            Log.i("Game:initRoyalAdNetwork() - Downloaded manifest", tostring(success))

            local function display_ad_callback(ad_config)
                -- @todo Check the ad config to determine if the ad should be shown.
                -- @todo Return a key that represents the value being compared.
                return true, config.state.evolution
            end

            adVendor = AdVendor(royalClient.getAdConfig(), AdStylizer(), manifest.getAdUnits(), display_ad_callback)
        end)
        promise.fail(function()
            Log.e("Game:initRoyalAdNetwork() - Failed to download manifest!")
            -- @todo Attempt to try again every N seconds for N times.
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

    function self.init(_writablePath, _appManager, _adServer, _iap, _socialManager, _royalClient)
        writablePath = _writablePath
        appManager = _appManager
        adServer = _adServer
        iap = _iap
        socialManager = _socialManager
        royalClient = _royalClient

        -- local saveFile = writablePath .. "game.save"

        shim.RandomizeSeed()
    end
end

return Game
