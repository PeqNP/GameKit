require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Warning)

local MediationAdFactory = require("mediation.AdFactory")
local AdManager = require("ad.Manager")
local Error = require("Error")
local BridgeResponse = require("bridge.BridgeResponse")

local ServerManager = require("ad.ServerManager")

describe("ServerManager - when no service is provided", function()
    local subject
    local bridge

    before_each(function()
        bridge = require("bridge.modules.ad")
        local adConfig = {}
        local networks = {}
        subject = ServerManager(bridge, adConfig, networks)
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
        local _error

        before_each(function()
            _error = nil

            promise = subject.fetchConfig()
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
end)
