--
-- Provides the Ad network; which provides a client interface to download Ads
-- and vend them when necessary.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"
require "HTTPResponseType"

local Promise = require("Promise")
local AdRequestCallback = require("royal.AdRequestCallback")

local Client = Class()

function Client.new(self)
    local http
    local writer
    local config
    local url
    local cachedManifest

    local manifest
    local promise
    local requests = {}
    local errors = {}
    local callbacks = {}

    local inTransaction = false
    local plistLoaded = false

    function self.init(_http, _writer, _config, _url, _cachedManifest)
        http = _http
        writer = _writer
        config = _config
        url = _url
        cachedManifest = _cachedManifest
    end

    local function startTransaction()
        inTransaction = true
    end

    local function commitTransaction()
        inTransaction = false
    end

    local function clean()
        callbacks = {}

        if plistLoaded then
            cc.SpriteFrameCache:getInstance():removeSpriteFrames(config.getPlistFilepath())
            plistLoaded = false
        end
    end

    local function finish()
        if #requests > 0 then
            return
        end
        if inTransaction then
            return
        end
        local success = #errors == 0 and true or false
        if success then
            for _, c in ipairs(callbacks) do
                c.execute()
            end
            -- @note More requests may have been added to the stack since
            -- 'execute' was called.
            if #requests == 0 then
                -- @todo Probably need to set the search resolution path to this path.
                cc.SpriteFrameCache:getInstance():addSpriteFrames(config.getPlistFilepath())
                plistLoaded = true
                promise.resolve(manifest)
            else
                -- Clean callbacks if there are more requests.
                callbacks = {}
            end
        else
            clean()
            promise.reject(Error(1, "Failed to download Royal ad config."))
        end
    end

    local function getRequest(file, responseType, callback)
        local request = http.get(url .. file, responseType)
        request.done(function(status, contents)
            table.insert(callbacks, AdRequestCallback(callback, file, contents))
        end)
        request.fail(function(status, _error)
            table.insert(errors, _error)
        end)
        request.always(function(status)
            local pos = 1
            for _, v in ipairs(requests) do
                if v == request then
                    table.remove(requests, pos)
                    break
                end
                pos = pos + 1
            end
            Log.d("royal.Client:getRequest() - File (%s) status (%s)", file, status)
            finish()
        end)
        return request
    end

    local function pushRequest(file, responseType, callback)
        table.insert(requests, getRequest(file, responseType, callback))
    end

    function self.setCachedManifest(m)
        cachedManifest = m
    end

    -- Returns the number of in-flight requests.
    function self.getNumRequests()
        return #requests
    end

    function self.getErrors()
        return errors
    end

    local function callback__file(file, response)
        -- Get only the last part of the file.
        local parts = string.split(file, "/")
        local filename = parts[#parts]
        local path = config.getPath(filename)
        local file = LuaFile(path)
        file.write(response, "wb")
        return path
    end

    local function callback__plist(file, response)
        local p = callback__file(file, response)
    end

    local function callback__ads(file, response)
        local dict = json.decode(response)
        local dlManifest = AdManifestParser.singleton.fromDictionary(dict)
        if cachedManifest and cachedManifest.isActive(dlManifest.getCreated()) then
            Log.i("royal.Client:callback__ads() - Using cached manifest")
            return
        else
            Log.i("royal.Client:callback__ads() - Saving manifest to cache")
            callback__file(config.getConfigFilepath(), response)
            manifest = dlManifest
        end
        startTransaction()
        pushRequest(config.getImageVariant() .. "/" .. config.getPlistFilename(), HTTPResponseType.String, callback__plist)
        pushRequest(config.getImageVariant() .. "/" .. config.getImageFilename(), HTTPResponseType.Blob, callback__file)
        commitTransaction()
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
        errors = {}
        promise = Promise()
        startTransaction()
        pushRequest(config.getConfigFilename(), HTTPResponseType.String, callback__ads)
        commitTransaction()
        return promise
    end
end

return Client
