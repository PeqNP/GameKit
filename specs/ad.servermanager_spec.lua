require "specs.Cocos2d-x"

local Error = require("Error")

local ServerManager = require("ad.ServerManager")

describe("ServerManager - when no service is provided", function()
    local subject

    before_each(function()
        local bridge = {}
        local adConfig = {}
        local networks = {}
        subject = ServerManager(bridge, adConfig, networks)
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
