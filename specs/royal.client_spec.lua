--
-- TODO:
-- ? Fix: Make sure the sprite frames are not loaded into the cache until ALL files are downloaded.
--
require "lang.Signal"
require "specs.Cocos2d-x"
require "json"
require "Logger"
require "HTTPResponseType"

Log.setLevel(LogLevel.Warning)

local HTTP = require("shim.HTTP")
local LuaFile = require("LuaFile")
local Promise = require("Promise")
local AdConfig = require("royal.AdConfig")
local AdManifestParser = require("royal.AdManifestParser")
local AdManifest = require("royal.AdManifest")
local AdClient = require("royal.Client")
local AdUnit = require("royal.AdUnit")

describe("AdClient", function()
    local subject
    local http
    local file
    local config
    local url
    local cachedManifest

    before_each(function()
        http = HTTP()
        file = LuaFile()
        config = AdConfig("/path/")
        url = "http://www.example.com:80/ad/com.example.game"

        -- @note does not have default manifest in parameter list.
        subject = AdClient(http, file, config, url)
    end)

    describe("fetch config", function()
        local cache 
        local promise
        local adRequest
        local plistRequest
        local pngRequest
        local wasCalled
        local success
        local manifest

        local ad_called
        local plist_called
        local png_called

        before_each(function()
            ad_called = false
            plist_called = false
            png_called = false

            cache = cc.SpriteFrameCache:getInstance()
            stub(cache, "removeSpriteFrames")

            adRequest = Promise()
            plistRequest = Promise()
            pngRequest = Promise()

            function http.get(path, responseType, callback)
                if path == "http://www.example.com/ad/com.example.game/royal.json" then
                    ad_called = true
                    return adRequest
                elseif path == "http://www.example.com/ad/com.example.game/royal.plist" then
                    plist_called = true
                    return plistRequest
                elseif path == "http://www.example.com/ad/com.example.game/royal.png" then
                    png_called = true
                    return pngRequest
                else
                    assert("Invalid path: "..path)
                end
            end
            spy.on(http, "get")

            wasCalled = false
            promise = subject.fetchConfig()
            promise.done(function(_manifest)
                manifest = _manifest
            end)
            promise.fail(function(__error)
                _error = __error
            end)
            promise.always(function()
                wasCalled = true
            end)
        end)

        it("should NOT have made call to remove plist's sprite frames", function()
            assert.stub(cache.removeSpriteFrames).was_not.called()
        end)

        it("should have returned a Promise", function()
            assert.truthy(promise.kindOf(Promise))
        end)

        it("should have made request for json manifest", function()
            assert.truthy(ad_called)
        end)

        it("should have NOT sent plist request", function()
            assert.falsy(plist_called)
        end)

        it("should have NOT sent png request", function()
            assert.falsy(png_called)
        end)

        it("should still have network request in-flight", function()
            assert.falsy(wasCalled)
        end)

        it("should have one in-flight requests", function()
            assert.equals(1, subject.getNumRequests())
        end)

        describe("when the config is downloaded", function()
            local jsonDict
            local jsonStr

            before_each(function()
                jsonStr = "{'created': 1000, 'units': [{'id': 2, 'startdate': 4, 'enddate': 5, 'url': 'http://www.example.com', 'reward': 25, 'title': 'A title!', 'config': null}]}"
            end)

            -- @todo Add test when data provided to us from server is corrupted. This should
            -- use internal methods which already handle this breakage. But this must fail
            -- gracefully by rejecting the promise.

            describe("when there is no cached manifest", function()
                before_each(function()
                    stub(file, "write")
                    adResponse.resolve(200, jsonStr)
                end)

                it("should have saved the manifest to disk", function()
                    assert.stub(file.write).was.called_with("/path/royal.json", jsonStr, "wb")
                end)

                it("should have two new in-flight requests (one for plist and png)", function()
                    assert.equals(2, subject.getNumRequests())
                end)

                it("should have made request for plist", function()
                    assert.truthy(plist_called)
                end)

                it("should have made request for png", function()
                    assert.truthy(png_called)
                end)

                it("should not have resolved the promise yet", function()
                    assert.falsy(wasCalled)
                end)

                it("should have no errors", function()
                    local e = subject.getErrors()
                    assert.equals(0, #e)
                end)

                describe("when the remaining requests succeed", function()
                    before_each(function()
                        stub(cache, "addSpriteFrames")

                        plistRequest.resolve(200, "PLIST-DATA")
                        pngRequest.resolve(200, "PNG-DATA")
                    end)

                    it("should have no more in-flight requests", function()
                        assert.equals(0, subject.getNumRequests())
                    end)

                    it("should have resolved the promise", function()
                        assert.truthy(wasCalled)
                    end)

                    it("should have returned the manifest", function()
                        assert.truthy(manifest)
                        assert.equal(AdManifest, manifest.getClass())
                    end)

                    it("should have written plist to disk", function()
                        assert.stub(file.write).was.called_with("/path/royal.plist", "PLIST-DATA", "wb")
                    end)

                    it("should have written png to disk", function()
                        assert.stub(file.write).was.called_with("/path/royal.png", "PNG-DATA", "wb")
                    end)

                    it("should have made call to cache the plist", function()
                        assert.stub(cache.addSpriteFrames).was.called_with(cache, "/path/royal.plist")
                    end)

                    describe("when fetchConfig() is called a subsequent time", function()
                        before_each(function()
                            subject.fetchConfig()
                        end)

                        it("should have made call to clear the cache", function()
                            assert.stub(cache.removeSpriteFrames).was.called_with(cache, subject.getPlistFilepath())
                        end)
                    end)
                end)

                describe("when the remaining requests fail", function()
                    before_each(function()
                        plistRequest.reject(100, "Some error")
                        pngRequest.reject(404, "Resource not found")
                    end)

                    it("should have resolved the promise", function()
                        assert.truthy(wasCalled)
                    end)

                    it("should have returned failure", function()
                        assert.truthy(_error)
                        assert.equal(Error, _error.getClass())
                    end)

                    it("should have created two errors", function()
                        local e = subject.getErrors()
                        assert.equals(2, #e)
                    end)

                    -- @note Nothing should have been written to disk. There's no reason
                    -- to perform a sanity check.

                    describe("when fetch config is called a subsequent time", function()
                        before_each(function()
                            subject.fetchConfig()
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

            describe("when the cached manifest is the same", function()
                local cached

                before_each(function()
                    mock(file, true)
                    cached = AdManifest(1000, {})
                    subject.setCachedManifest(cached)
                    adResponse.resolve(200, jsonStr)
                end)

                it("should have resolved the promise", function()
                    assert.truthy(wasCalled)
                end)

                it("should have returned the cached manifest", function()
                    assert.truthy(manifest)
                    assert.equal(cached, manifest)
                end)

                -- @note Should not have made requests to plist/png files.
            end)

            describe("when the cached manifest is old", function()
                local cached

                before_each(function()
                    mock(file, true)
                    cached = AdManifest(999, {})
                    subject.setCachedManifest(cached)
                    adResponse.resolve(200, jsonStr)
                end)

                it("should NOT have resolved the promise", function()
                    assert.falsy(wasCalled)
                end)

                it("should have made request for plist", function()
                    assert.truthy(plist_called)
                end)

                it("should have made request for png", function()
                    assert.stub(png_called)
                end)
                
                -- @note The cycle should now be the same as if there was no cached manifest.
            end)
        end)

        describe("when the request fails", function()
            before_each(function()
                adRequest.reject(500, "Internal server error")
            end)

            it("should have failed", function()
                assert.truthy(_error)
                assert.equal(Error, _error.getClass())
                assert.equal(500, _error.getCode())
                assert.equal("Internal server error", _error.getMessage())
            end)

            -- @note No need to check if the plist/png files were downloaded. Those are
            -- sanity checks only.

            it("should have removed the number of in-flight requests", function()
                assert.equals(0, subject.getNumRequests())
            end)

            it("should have one error", function()
                local e = subject.getErrors()
                assert.equals(1, #e)
            end)

            it("should NOT have written any files to disk", function()
                assert.stub(file.write).was.not_called()
            end)
        end)
    end)

    -- @todo Make requests resolved out of order to ensure that the correct
    -- request is removed after it completes.
    -- @todo when two or more downloads fail.
end)
