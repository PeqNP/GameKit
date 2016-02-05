require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Warning)

local MediationAdConfig = require("mediation.AdConfig")
local MediationAdFactory = require("mediation.AdFactory")
local MediationService = require("mediation.Service")
local MediationConfig = require("mediation.Config")
local AdManager = require("ad.Manager")
local Error = require("Error")
local Promise = require("Promise")
local BridgeResponse = require("bridge.BridgeResponse")

local ServerManager = require("ad.ServerManager")

describe("ServerManager - when no service is provided", function()
    local subject
    local bridge
    local service

    before_each(function()
        bridge = require("bridge.modules.ad")
        local adConfig = {}
        local networks = {}
        service = MediationService()
        subject = ServerManager(bridge, adConfig, networks, service)
    end)

    context("ad.Manager factory", function()
        local adManager

        before_each(function()
            stub(bridge, "configure", mock(BridgeResponse(), true))
            local factory = mock(MediationAdFactory({}), true)
            adManager = subject.getAdManager(factory)
        end)

        it("should return an ad.Manager", function()
            assert.truthy(adManager)
            assert.equal(AdManager, adManager.getClass())
        end)
    end)

    context("fetch config", function()
        local promise
        local adManager
        local _error

        before_each(function()
            _error = nil
            promise = Promise()
            stub(service, "fetchConfig", promise)

            local fetch = subject.fetchConfig()
            fetch.done(function(_adManager)
                adManager = _adManager
            end)
            fetch.fail(function(__error)
                _error = __error
            end)
        end)

        context("when the request succeeds", function()
            local config

            context("when the server has configs", function()
                before_each(function()
                    config = MediationConfig()
                    stub(config, "getAds", {MediationAdConfig()})

                    promise.resolve(config)
                end)

                it("should have returned an AdManager", function()
                    assert.truthy(adManager)
                    assert.equal(AdManager, adManager.getClass())
                end)
            end)

            context("when the server has NO configs", function()
                before_each(function()
                    config = MediationConfig()
                    stub(config, "getAds", {})

                    promise.resolve(config)
                end)

                it("should have returned an Error", function()
                    assert.truthy(_error)
                    assert.equal(503, _error.getCode())
                    assert.equal("Server has no configs.", _error.getMessage())
                end)
            end)
        end)

        context("when the request fails", function()
            local _testError

            before_each(function()
                _testError = Error(-1, "Failed to fetch")
                promise.reject(_testError)
            end)

            it("should have returned an Error", function()
                assert.truthy(_error)
                assert.equal(_testError, _error)
            end)
        end)
    end)
end)

describe("ServerManager w/ no server config", function()
    local subject
    local _error

    before_each(function()
        _error = nil

        subject = ServerManager(bridge, adConfig, networks, service)
        local promise = subject.fetchConfig()
        promise.fail(function(__error)
            _error = __error
        end)
    end)

    it("should return an error immediately", function()
        assert.truthy(_error)
        assert.equal(Error, _error.getClass())
        assert.equal(500, _error.getCode())
        assert.equal("mediation.Service was not provided.", _error.getMessage())
    end)
end)
