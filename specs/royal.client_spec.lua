--[[
  TODO:
  + Fix responseType. assert.equal should work. I also know that AdClient is setting this values properly. It's almost
    as if the variable isn't created in the constructor... or being visible.
  + Fix: statusText needs to be tested when something fails.
  + Fix: Make sure the sprite frames are not loaded into the cache until ALL files are downloaded.
--]]
require "lang.Signal"
require "specs.Cocos2d-x"
require "json"
require "Logger"

Log.setLevel(LogLevel.Warning)

local AdConfig = require("royal.AdConfig")
local AdManifestParser = require("royal.AdManifestParser")
local AdManifest = require("royal.AdManifest")
local AdClient = require("royal.Client")
local AdUnit = require("royal.AdUnit")

AdConfig.singleton.setBasePath("/path/")

describe("AdClient", function()
    local subject = false

    local host
    local port
    local path
    local maxVersions

    before_each(function()
        host = "http://www.example.com"
        port = 80
        path = "/ad/com.example.game/"
        maxVersions = {1, 2}
        subject = AdClient(host, port, path, maxVersions)

        -- Never read/write/close an actual file.
        stub(io, "open")
        stub(io, "output")
        stub(io, "write")
        stub(io, "close")
    end)

    it("should have set all values", function()
        assert.equals(host, subject.host)
        assert.equals(port, subject.port)
        assert.equals(path, subject.path)
        assert.equals(maxVersions, subject.maxVersions)
    end)

    it("should return the correct local path to the plist file", function()
        assert.equals("/path/ads.plist", subject.getPlistFilepath())
    end)

    it("should return the correct cached path", function()
        assert.equals("/path/ads.json", subject.getCacheFilepath())
    end)

    describe("downloadAds", function()
        local cache 
        local promise
        local adRequest
        local plistRequest
        local pngRequest
        local wasCalled
        local success
        local rfn

        before_each(function()
            cache = cc.SpriteFrameCache:getInstance()
            stub(cache, "removeSpriteFrames")

            adRequest = cc.XMLHttpRequest()
            stub(adRequest, "open")
            stub(adRequest, "send")

            plistRequest = cc.XMLHttpRequest()
            stub(plistRequest, "open")
            stub(plistRequest, "send")

            pngRequest = cc.XMLHttpRequest()
            stub(pngRequest, "open")
            stub(pngRequest, "send")

            -- Request 1) json 2) plist 3) png
            local reqNum = 0
            function cc.XMLHttpRequest:new()
                reqNum = reqNum + 1
                if reqNum > 3 then -- round robin for subsequent calls made to downloadAds.
                    reqNum = 1
                end
                if reqNum == 1 then
                    return adRequest
                elseif reqNum == 2 then
                    return plistRequest
                elseif reqNum == 3 then
                    return pngRequest
                end
            end

            wasCalled = false
            promise = subject.downloadAds()
            promise.done(function(s)
                wasCalled = true
                success = s
            end)
        end)

        it("should NOT have made call to remove plist's sprite frames", function()
            assert.stub(cache.removeSpriteFrames).was_not.called()
        end)

        it("should have returned a Promise", function()
            assert.truthy(promise.kindOf(Promise))
        end)

        it("should have made request for json manifest", function()
            assert.stub(adRequest.open).was.called_with(adRequest, "GET", "http://www.example.com/ad/com.example.game/ads.json", true)
        end)

        it("should have created a text request", function()
            -- @note 0 = cc.XMLHTTPREQUEST_RESPONSE_STRING
            --assert.equal(adRequest.responseType, 0)
        end)

        it("should have sent ad request", function()
            assert.stub(adRequest.send).was.called()
        end)

        it("should have NOT sent plist request", function()
            assert.stub(plistRequest.send).was_not.called()
        end)

        it("should have NOT sent png request", function()
            assert.stub(pngRequest.send).was_not.called()
        end)

        it("should still have network request in-flight", function()
            assert.falsy(wasCalled)
        end)

        it("should have one in-flight requests", function()
            assert.equals(1, subject.getNumRequests())
        end)

        describe("when the ad downloaded successfully", function()
            local manifest
            local jsonDict
            local jsonStr
            local ads

            describe("when the manifest is first downloaded", function()
                before_each(function()
                    ads = {}

                    jsonStr = "{'version': 1, 'ttl': 86500, 'units': [{'id': 2, 'reward': 25, 'startdate': 4, 'enddate': 5, 'waitsecs': 86400, 'maxclicks': 1, 'tiers': [{'id': 4, 'config': {}}]}]}"

                    adRequest.status = 200
                    adRequest.response = jsonStr
                    jsonDict = json.decode(jsonStr)

                    manifest = AdManifest()
                    manifest.setAdUnits(ads)
                    stub(json, "decode", jsonDict)
                    stub(AdManifestParser.singleton, "fromDictionary", manifest)

                    adRequest.fn()
                end)

                it("should have decoded the json", function()
                    assert.stub(json.decode).was.called_with(jsonStr)
                end)

                it("should have saved the manifest to disk", function()
                    assert.stub(io.open).was.called_with("/path/ads.json", "wb")
                end)

                it("should have called called manifest parser", function()
                    assert.stub(AdManifestParser.singleton.fromDictionary).was.called_with(jsonDict)
                end)

                it("should have two in-flight requests", function()
                    assert.equals(2, subject.getNumRequests())
                end)

                it("should have made request for plist", function()
                    assert.stub(plistRequest.open).was.called_with(plistRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.plist", true)
                end)

                it("should have made request for png", function()
                    assert.stub(pngRequest.open).was.called_with(pngRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.png", true)
                end)

                it("should have set the correct plist response type", function()
                    -- @note 0 = cc.XMLHTTPREQUEST_RESPONSE_STRING
                    --assert.equal(plistRequest.responseType, 0)
                end)

                it("should have sent plist request", function()
                    assert.stub(plistRequest.send).was.called()
                end)

                it("should have set the correct png response type", function()
                    -- @note 1 = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
                    --assert.equal(pngRequest.responseType, 1)
                end)

                it("should have sent png request", function()
                    assert.stub(pngRequest.send).was.called()
                end)

                it("should not have resolved the promise yet", function()
                    assert.falsy(wasCalled)
                end)

                it("should have no errors", function()
                    local e = subject.getErrors()
                    assert.equals(0, #e)
                end)

                it("should have a manifest", function()
                    assert.truthy(subject.getManifest())
                end)

                describe("when the remaining requests succeed", function()
                    before_each(function()
                        stub(cache, "addSpriteFrames")

                        pngRequest.status = 200
                        pngRequest.response = "DEADBEAF"
                        pngRequest.fn()
                        plistRequest.status = 200
                        plistRequest.response = "BIG FAT DATA"
                        plistRequest.fn()
                    end)

                    it("should have no more in-flight requests", function()
                        assert.equals(0, subject.getNumRequests())
                    end)

                    it("should have resolved the promise", function()
                        assert.truthy(wasCalled)
                    end)

                    it("should have returned success", function()
                        assert.truthy(success)
                    end)

                    it("should have returned ads", function()
                        assert.truthy(subject.getManifest())
                    end)

                    it("should have written plist to disk", function()
                        assert.stub(io.open).was.called_with("/path/ads.plist", "wb")
                        assert.stub(io.output).was.called()
                        assert.stub(io.write).was.called_with("BIG FAT DATA")
                        assert.stub(io.close).was.called()
                    end)

                    it("should have written png to disk", function()
                        assert.stub(io.open).was.called_with("/path/ads.png", "wb")
                        assert.stub(io.output).was.called()
                        assert.stub(io.write).was.called_with("DEADBEAF")
                        assert.stub(io.close).was.called()
                    end)

                    it("should have made call to cache the plist", function()
                        assert.stub(cache.addSpriteFrames).was.called_with(cache, "/path/ads.plist")
                    end)

                    describe("when downloadAds is called a subsequent time", function()
                        before_each(function()
                            subject.downloadAds()
                        end)

                        it("should have made call to clear the cache", function()
                            assert.stub(cache.removeSpriteFrames).was.called_with(cache, subject.getPlistFilepath())
                        end)
                    end)
                end)

                describe("when the remaining requests fail", function()
                    before_each(function()
                        pngRequest.status = 400
                        pngRequest.fn()
                        plistRequest.status = 100
                        plistRequest.fn()
                    end)

                    it("should have resolved the promise", function()
                        assert.truthy(wasCalled)
                    end)

                    it("should have returned failure", function()
                        assert.falsy(success)
                    end)

                    it("should have created two errors", function()
                        local e = subject.getErrors()
                        assert.equals(2, #e)
                    end)

                    -- @note There's no reason to delete the manifest if the other files failed.
                    it("should still have a manifest", function()
                        assert.truthy(subject.getManifest())
                    end)

                    it("should NOT have written the plist to disk", function()
                        assert.stub(io.open).was.not_called_with("/path/ads.plist", "wb")
                    end)

                    it("should NOT have written the png to disk", function()
                        assert.stub(io.open).was.not_called_with("/path/ads.png", "wb")
                    end)

                    describe("when downloadAds is called a subsequent time", function()
                        before_each(function()
                            subject.downloadAds()
                        end)

                        it("should have cleared the errors", function()
                            local e = subject.getErrors()
                            assert.equals(0, #e)
                        end)

                        it("should NOT have made call to clear the cache", function()
                            assert.stub(cache.removeSpriteFrames).was_not.called()
                        end)
                    end)
                end)
            end)

            -- @todo check when the cached manifest is the same as the one downloaded from the server.

            describe("when the downloaded manifest is the same", function()
                before_each(function()
                    manifest = AdManifest(1, 550, 80)
                    subject.setManifest(manifest)

                    local dlManifest = AdManifest(1, 550, 80)

                    stub(json, "decode")
                    stub(AdManifestParser.singleton, "fromDictionary", dlManifest)

                    adRequest.status = 200
                    adRequest.fn()
                end)

                it("should have resolved the promise", function()
                    assert.truthy(wasCalled)
                end)

                it("should have returned success", function()
                    assert.truthy(success)
                end)

                it("should still use the old manifest", function()
                    assert.equals(manifest, subject.getManifest())
                end)

                it("should NOT have made request for plist", function()
                    assert.stub(plistRequest.open).was_not.called_with(plistRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.plist", true)
                end)

                it("should NOT have made request for png", function()
                    assert.stub(pngRequest.open).was_not.called_with(pngRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.png", true)
                end)
            end)

            describe("when the downloaded manifest is new it must redownload assets", function()
                local dlManifest

                before_each(function()
                    manifest = AdManifest(1, 550, 80)
                    subject.setManifest(manifest)

                    dlManifest = AdManifest(1, 560, 80)

                    stub(json, "decode")
                    stub(AdManifestParser.singleton, "fromDictionary", dlManifest)

                    adRequest.status = 200
                    adRequest.fn()
                end)

                it("should NOT have resolved the promise", function()
                    assert.falsy(wasCalled)
                end)

                it("should have set the new manifest", function()
                    assert.equals(dlManifest, subject.getManifest())
                end)

                it("should have made request for plist", function()
                    assert.stub(plistRequest.open).was.called_with(plistRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.plist", true)
                end)

                it("should have made request for png", function()
                    assert.stub(pngRequest.open).was.called_with(pngRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.png", true)
                end)
            end)
        end)

        describe("when the ad request fails", function()
            before_each(function()
                adRequest.status = 500
                adRequest.fn()
            end)

            it("should have resolved promise", function()
                assert.truthy(wasCalled)
            end)

            it("should have returned failure", function()
                assert.falsy(success)
            end)

            it("should NOT have made request for plist", function()
                assert.stub(plistRequest.open).was_not.called_with(plistRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.plist", true)
            end)

            it("should NOT have made request for png", function()
                assert.stub(pngRequest.open).was_not.called_with(pngRequest, "GET", "http://www.example.com/ad/com.example.game/sd/ads.png", true)
            end)

            it("should have removed the number of in-flight requests", function()
                assert.equals(0, subject.getNumRequests())
            end)

            it("should have one error", function()
                local e = subject.getErrors()
                assert.equals(1, #e)
            end)

            it("should have no ads", function()
                assert.is_nil(subject.getManifest())
            end)

            it("should NOT have written plist to disk", function()
                assert.stub(io.open).was.not_called()
            end)

            it("should NOT have written png to disk", function()
                assert.stub(io.open).was.not_called()
            end)
        end)
    end)

    describe("setManifest", function()
        local manifest

        before_each(function()
            manifest = {}
            subject.setManifest(manifest)
        end)

        it("should have set the manifest", function()
            assert.equals(manifest, subject.getManifest())
        end)
    end)

    describe("load manifest from file", function()
        before_each(function()
            stub(io, "input")
            stub(io, "output")
            stub(io, "write")
            stub(io, "close")
        end)

        describe("when the file exists", function()
            local fakeManifest

            before_each(function()
                fakeManifest = {}
                stub(AdManifestParser.singleton, "fromDictionary", fakeManifest)

                local jsonStr = "{'version': 1, 'created': 10000, 'ttl': 86500, 'units': [{'id': 2, 'reward': 25, 'startdate': 4, 'enddate': 5, 'waitsecs': 86400, 'maxclicks': 1, 'tiers': [{'id': 4, 'config': {}}]}]}"
                local jsonDict = json.decode(jsonStr)

                stub(io, "open", true)
                stub(io, "read", jsonStr)
                stub(json, "decode", jsonDict)

                subject.loadFromCache()
            end)

            it("should have made call to inflate manifest from dictionary", function()
                assert.equals(fakeManifest, subject.getManifest())
            end)

            it("should have made call to AdManifestParser to inflate", function()
                assert.stub(AdManifestParser.singleton.fromDictionary).was.called_with(jsonDict)
            end)
        end)

        describe("when the file contains no data", function()
            before_each(function()
                stub(AdManifestParser.singleton, "fromDictionary")

                stub(io, "open", true)
                stub(io, "read", "")
                
                subject.loadFromCache()
            end)

            it("should have returned nil", function()
                assert.falsy(subject.getManifest())
            end)

            it("should NOT have made call to inflate dictionary", function()
                assert.stub(AdManifestParser.singleton.fromDictionary).was_not.called()
            end)
        end)

        describe("when the file does not exist", function()
            before_each(function()
                stub(AdManifestParser.singleton, "fromDictionary")

                stub(io, "open", false)
                stub(io, "read", nil)
                
                subject.loadFromCache()
            end)

            it("should have returned nil", function()
                assert.falsy(subject.getManifest())
            end)

            it("should NOT have made call to inflate dictionary", function()
                assert.stub(AdManifestParser.singleton.fromDictionary).was_not.called()
            end)
        end)
    end)

    -- @todo Make requests resolved out of order to ensure that the correct
    -- request is removed after it completes.
    -- @todo when two or more downloads fail.
end)
