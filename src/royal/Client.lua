--
-- Provides the Ad network; which provides a client interface to download Ads
-- and vend them when necessary.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require("json")
require("HTTPResponseType")
require("Logger")

local Promise = require("Promise")
local AdManifest = require("royal.AdManifest")
local Error = require("Error")
local shim = require("shim.System")

local Client = Class()

function Client.new(self)
    local http
    local config
    local url
    local cachedManifest

    local promise
    local requests = {}
    local errors = {}
    local callbacks = {}

    local plistLoaded = false

    function self.init(_http, _config, _url)
        http = _http
        config = _config
        url = _url
    end

    function self.getAdConfig()
        return config
    end

    function self.setCachedManifest(manifest)
        cachedManifest = manifest
    end

    function self.getCachedManifest()
        return cachedManifest
    end

    local function clean()
        callbacks = {}
        errors = {}

        if plistLoaded then
            cc.SpriteFrameCache:getInstance():removeSpriteFrames(config.getPlistFilepath())
            plistLoaded = false
        end
    end

    local function removeAllFiles()
        shim.RemoveFile(config.getConfigFilename())
        shim.RemoveFile(config.getPlistFilepath())
        shim.RemoveFile(config.getImageFilepath())
    end

    local function getRequest(file, responseType, callback)
        local request = http.get(url .. file, responseType)
        request.done(function(status, contents)
            if callback then
                callback(file, contents)
            end
        end)
        request.fail(function(status, _error)
            table.insert(errors, _error)
        end)
        request.always(function(status)
            Log.d("royal.Client:getRequest() - File (%s) status (%s)", file, status)
        end)
        return request
    end

    function self.getErrors()
        return errors
    end

    local function writeFile(file, contents)
        -- Get only the last part of the file (remove 'sd', 'hd', etc.)
        local parts = string.split(file, "/")
        local filename = parts[#parts]
        config.write(filename, contents, "wb")
    end

    local function writeManifest(contents)
        local dict = json.decode(contents)
        local manifest = AdManifest.fromDictionary(dict)
        if not manifest then
            if cachedManifest then -- Fallback to cached manifest if possible.
                return cachedManifest, false
            end
            Log.w("royal.Client:writeManifest() - Manifest is malformed")
            return nil, false
        end
        if cachedManifest and cachedManifest.isActive(manifest.getCreated()) then
            Log.d("royal.Client:writeManifest() - Using cached manifest")
            local download = false
            -- Make sure all assets exist. Note: even if the assets exist, they may still be
            -- in an invalid state, which is not part of the checks.
            if not shim.FileExists(config.getPlistFilepath()) then
                Log.w("royal.Client.writeManifest: Cached manifest exists but no plist (%s)", config.getPlistFilepath())
                download = true
            end
            if not shim.FileExists(config.getImageFilepath()) then
                Log.w("royal.Client.writeManifest: Cached manifest exists but image does not exist (%s)", config.getImageFilepath())
                download = true
            end
            local imageData = shim.GetFileData(config.getImageFilepath())
            if not imageData then
                Log.w("royal.Client.writeManifest: Cached manifest exists but image is corrupt (%s)", config.getImageFilepath())
                download = true
            end
            return cachedManifest, download
        end
        Log.d("royal.Client:callback__ads() - Saving manifest to cache")
        writeFile(config.getConfigFilename(), contents)
        return manifest, true
    end

    local function downloadResources(manifest)
        return Promise.when(
            getRequest(config.getImageVariant() .. "/" .. config.getPlistFilename(), HTTPResponseType.String, writeFile),
            getRequest(config.getImageVariant() .. "/" .. config.getImageFilename(), HTTPResponseType.Blob, writeFile)
        )
    end

    --
    -- Download ad configuration from the server.
    --
    -- Please note that this will clear all previously downloads ad config.
    --
    -- @return Promise
    --
    function self.fetchConfig()
        clean()
        promise = Promise()
        local request = getRequest(config.getConfigFilename(), HTTPResponseType.String)
        request.done(function(status, contents)
            local manifest, download = writeManifest(contents)
            if not manifest then
                promise.reject(Error(1, "Manifest failed to be decoded"))
                removeAllFiles()
                return
            end
            if download then
                local resources = downloadResources()
                resources.done(function()
                    Log.i("royal.Client.fetchConfig: Loading plist @ path (%s)", config.getPlistFilepath())
                    cc.SpriteFrameCache:getInstance():addSpriteFrames(config.getPlistFilepath())
                    local adUnits = manifest.getAdUnits()
                    -- Sanity: make sure all frames are available.
                    if adUnits and #adUnits > 0 then
                        for _, unit in adUnits do
                            local imageName = unit.getBannerName()
                            local frame = shim.GetSpriteFrame(imageName)
                            -- Destroy cache and redownload at another time.
                            if not frame then
                                promise.reject(Error(3, "royal.Client.fetchConfig: One or more of the downloaded images is corrupt."))
                                removeAllFiles()
                                return
                            end
                        end
                    end
                    plistLoaded = true
                    promise.resolve(manifest)
                end)
                resources.fail(function()
                    promise.reject(Error(2, "Failed to download resources"))
                    removeAllFiles()
                end)
            else
                cc.SpriteFrameCache:getInstance():addSpriteFrames(config.getPlistFilepath())
                promise.resolve(manifest)
            end
        end)
        request.fail(function(status, _error)
            promise.reject(Error(status, _error))
            removeAllFiles()
        end)
        return promise
    end
end

return Client
