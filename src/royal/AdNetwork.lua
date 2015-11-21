--
-- Provides the Ad network; which provides a client interface to download Ads
-- and vend them when necessary.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"
require "Promise"

require "royal.AdManifestParser"
require "royal.AdRequestCallback"

AdNetwork = Class()

function AdNetwork.new(self)
    self.delegate = false -- Assign if you wish to get callbacks in regards to progress, etc.

    local manifest
    local promise
    local requests = {}
    local errors = {}
    local callbacks = {}

    local plistLoaded = false

    function self.init(host, port, path, maxVersions)
        self.host = host
        self.port = port
        self.path = path
        self.maxVersions = maxVersions
    end

    local function clean()
        callbacks = {}

        if plistLoaded then
            cc.SpriteFrameCache:getInstance():removeSpriteFrames(self.getPlistFilepath())
            plistLoaded = false
        end
    end

    local function finish()
        if #requests > 0 then
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
                cc.SpriteFrameCache:getInstance():addSpriteFrames(self.getPlistFilepath())
                plistLoaded = true
                promise.resolve(true)
            else
                -- Clean callbacks if there are more requests.
                callbacks = {}
            end
        else
            clean()
            promise.resolve(false)
        end
    end

    local function getRequest(file, responseType, callback)
        local fullpath = self.host .. self.path .. file
        Log.d("getRequest: GET (%s)", fullpath)

        local request = cc.XMLHttpRequest:new()
        local function callback__complete()
            -- @todo Process data; write to disk, etc.
            if request.status < 200 or request.status > 299 then
                table.insert(errors, request.statusText)
            else
                table.insert(callbacks, AdRequestCallback(callback, file, request.response))
            end
            local pos = 1
            for _, v in ipairs(requests) do
                if v == request then
                    table.remove(requests, pos)
                    break
                end
                pos = pos + 1
            end
            Log.d("File (%s) status (%s)", fullpath, request.status)
            finish()
        end
        request.responseType = responseType
        request:registerScriptHandler(callback__complete)
        request:open("GET", fullpath, true)
        return request
    end

    local function pushRequest(file, responseType, callback)
        table.insert(requests, getRequest(file, responseType, callback))
    end

    local function sendRequests()
        -- Create all requests at the same time. This is necessary to ensure
        -- possible race-conditions which could prevent the promise to be
        -- resolved prematurely. All requests must be known before we send
        -- them.
        for _, r in ipairs(requests) do
            -- @fixme Do not send if already sent.
            r:send()
        end
    end

    --[[ Returns the path where the plist file will be/was saved locally. ]]--
    function self.getPlistFilepath()
        return AdConfig.singleton.getPath("ads.plist")
    end

    --[[ Returns the number of in-flight requests. ]]--
    function self.getNumRequests()
        return #requests
    end

    function self.getErrors()
        return errors
    end

    --[[ Set ads to round-robin. This should only be used for testing. ]]--
    function self.setManifest(m)
        manifest = m
    end

    function self.getManifest()
        return manifest
    end

    local function callback__file(file, response)
        -- Get only the last part of the file.
        local parts = string.split(file, "/")
        local f = parts[#parts]
        local p = AdConfig.singleton.getPath(f)
        local fh = io.open(p, "wb")
        io.output(fh)
        io.write(response)
        io.close(fh)
        return p
    end

    local function callback__plist(file, response)
        local p = callback__file(file, response)
    end

    local function callback__ads(file, response)
        local dict = json.decode(response)
        local dlManifest = AdManifestParser.singleton.fromDictionary(dict)
        if manifest and manifest.isActive(dlManifest.getCreated()) then
            Log.i("Using cached ads.json manifest")
            return
        else
            Log.i("Saving ads.json to cache")
            callback__file(self.getCacheFilepath(), response)
            manifest = dlManifest
        end
        pushRequest(AdConfig.singleton.getImageVariant() .. "/ads.plist", cc.XMLHTTPREQUEST_RESPONSE_STRING, callback__plist)
        pushRequest(AdConfig.singleton.getImageVariant() .. "/ads.png", cc.XMLHTTPREQUEST_RESPONSE_BLOB, callback__file)
        sendRequests()
    end

    function self.getCacheFilepath()
        return AdConfig.singleton.getPath("ads.json")
    end

    function self.loadFromCache()
        local fh = io.open(self.getCacheFilepath(), "r")
        if not fh then
            return
        end
        io.input(fh)
        local jsonStr = io.read("*all")
        io.close(fh)
        if not jsonStr or string.len(jsonStr) < 1 then
            Log.d("Cached ads.json file does not exist")
            return
        end
        local dict = json.decode(jsonStr)
        manifest = AdManifestParser.singleton.fromDictionary(dict)
    end

    --[[ Download new ads from the server.

      Please note that this will clear all previously downloads ads.

      @return Promise
    --]]
    function self.downloadAds()
        clean()
        errors = {}
        promise = Promise()
        pushRequest("ads.json", cc.XMLHTTPREQUEST_RESPONSE_STRING, callback__ads)
        sendRequests()
        return promise
    end
end
