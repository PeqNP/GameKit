
require "lang.Signal"
require "specs.Cocos2d-x"
require "json"
require "Logger"

Log.setLevel(LogLevel.Error)

require("HTTPResponseType")

local HTTP = require("shim.HTTP")
local Promise = require("Promise")
local MediationConfig = require("mediation.Config")
local MediationService = require("mediation.Service")
local MediationAdConfig = require("mediation.AdConfig")

describe("MediationService", function()
    local subject
    local http
    local url

    before_each(function()
        http = HTTP()
        url = "http://www.example.com:80/ad/com.example.game/mediation.json"
        subject = MediationService(http, url)
    end)

    describe("fetchConfig", function()
        local promise
        local _error
        local payload

        before_each(function()
            payload = nil
            _error = nil

            promise = Promise()
            stub(http, "get", promise)

            local request = subject.fetchConfig()
            request.done(function(p)
                payload = p
            end)
            request.fail(function(__error)
                _error = __error
            end)
        end)

        it("should have made request for json manifest", function()
            assert.stub(http.get).was.called_with("http://www.example.com:80/ad/com.example.game/mediation.json", HTTPResponseType.String)
        end)

        it("should still have network request in-flight", function()
            assert.falsy(payload)
        end)

        describe("when the request is successful", function()
            local jsonStr

            before_each(function()
                jsonStr = '{"version": 1, "ads": [{"adnetwork": 1, "adtype": 1, "adimpressiontype": 1, "frequency": 50, "reward": 50}]}'
                promise.resolve(200, jsonStr)
            end)

            it("should have returned mediation.Config", function()
                assert.truthy(payload.kindOf(MediationConfig))
                assert.equals(1, payload.getVersion())
                local ads = payload.getAds()
                assert.equals(1, #ads)
                assert.truthy(ads[1].kindOf(MediationAdConfig))
            end)
        end)

        describe("when the request fails", function()
            before_each(function()
                promise.reject(500, "An error")
            end)

            it("should have failed", function()
                assert.truthy(_error)
                assert.equal(-1, _error.getCode())
                assert.equal("Failed to retrieve MediationAdConfig(s) from server.", _error.getMessage())
            end)
        end)
    end)
end)
