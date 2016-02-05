
require "lang.Signal"
require "specs.Cocos2d-x"
require "json"
require "Logger"

Log.setLevel(LogLevel.Error)

local Promise = require("Promise")
local MediationConfig = require("mediation.Config")
local MediationService = require("mediation.Service")
local MediationAdConfig = require("mediation.AdConfig")

describe("MediationService", function()
    local subject

    local host
    local port
    local path

    before_each(function()
        host = "http://www.example.com"
        port = 80
        path = "/ad/com.example.game/mediation.json"
        subject = MediationService(host, port, path)

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
    end)

    describe("fetchConfig", function()
        local promise
        local request
        local wasCalled
        local _error
        local payload

        before_each(function()
            payload = nil
            request = cc.XMLHttpRequest()
            stub(request, "open")
            stub(request, "send")

            function cc.XMLHttpRequest:new()
                return request
            end

            wasCalled = false
            promise = subject.fetchConfig()
            promise.done(function(p)
                wasCalled = true
                payload = p
            end)
            promise.fail(function(__error)
                _error = __error
            end)
        end)

        it("should have set the correct response type", function()
            assert.truthy(request.responseType)
            assert.equals(cc.XMLHTTPREQUEST_RESPONSE_STRING, request.responseType)
        end)

        it("should have returned a Promise", function()
            assert.truthy(promise.kindOf(Promise))
        end)

        it("should have made request for json manifest", function()
            assert.stub(request.open).was.called_with(request, "GET", "http://www.example.com:80/ad/com.example.game/mediation.json", true)
        end)

        it("should have sent ad request", function()
            assert.stub(request.send).was.called()
        end)

        it("should still have network request in-flight", function()
            assert.falsy(wasCalled)
        end)

        describe("when the ad downloaded successfully", function()
            local manifest
            local jsonDict
            local jsonStr
            local ads

            describe("when the config download successfully", function()
                before_each(function()
                    ads = {}

                    jsonStr = '{"version": 1, "ads": [{"adnetwork": 1, "adtype": 1, "adimpressiontype": 1, "frequency": 50, "reward": 50}]}'

                    request.status = 200
                    request.response = jsonStr
                    jsonDict = json.decode(jsonStr)

                    request.fn()
                end)

                it("should have returned one ad config", function()
                    assert.truthy(payload.kindOf(MediationConfig))
                    assert.equals(1, payload.getVersion())
                    local ads = payload.getAds()
                    assert.equals(1, #ads)
                    assert.truthy(ads[1].kindOf(MediationAdConfig))
                end)
            end)

            describe("when the config fails to download", function()
                before_each(function()
                    request.status = 500
                    request.fn()
                end)

                it("should have failed", function()
                    assert.truthy(_error)
                    assert.equal(-1, _error.getCode())
                    assert.equal("Failed to retrieve MediationAdConfig(s) from server.", _error.getMessage())
                end)
            end)
        end)
    end)
end)
