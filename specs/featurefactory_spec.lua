require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Warning)

local AdServerConfig = require("ad.ServerConfig")
local AdServerManager = require("ad.ServerManager")
local AppManager = require("app.Manager")
local BridgeAdaptor = require("bridge.BridgeAdaptor")
local IAP = require("iap.IAP")
local SocialManager = require("social.Manager")
local RoyalClient = require("royal.Client")
local LuaFile = require("LuaFile")
local HTTP = require("shim.HTTP")
local AdConfig = require("royal.AdConfig")
local AdManifest = require("royal.AdManifest")

local FeatureFactory = require("FeatureFactory")

describe("FeatureFactory", function()
    local subject

    before_each(function()
        function BridgeAdaptor.getAdaptor()
            return mock(BridgeAdaptor(), true)
        end

        subject = FeatureFactory("ios")
    end)

    it("should create an app.Manager", function()
        local appManager = subject.getAppManager()
        assert.equal(AppManager, appManager.getClass())
    end)

    it("should create an iap.IAP", function()
        local tickets = {}
        local iap = subject.getIAP(tickets)
        assert.equal(IAP, iap.getClass())
    end)

    it("should create an ad.ServerManager", function()
        local adConfig = {}
        local networks = {}
        local adServer = AdServerConfig("http://www.example.com", 80, "/ad/ios/mediation.json")
        local server = subject.getAdManager(adConfig, networks, adServer)
        assert.equal(AdServerManager, server.getClass())
    end)
    
    it("should create a social.Manager", function()
        local social = subject.getSocialManager()
        assert.equal(SocialManager, social.getClass())
    end)

    context("creating a royal.Client", function()
        local client
        local manifest

        before_each(function()
            local http = HTTP()
            local config = AdConfig(LuaFile(), "/writable/path")
            manifest = AdManifest()

            stub(config, "read", "{\"key\": 1}")
            stub(AdManifest, "fromJson", manifest)

            client = subject.getRoyalClient(http, config, "http://www.example.com:80/ad/ios/")
        end)

        it("should create a royal.Manager", function()
            assert.equal(RoyalClient, client.getClass())
        end)

        it("should have set the cached manfiest", function()
            assert.equal(manifest, client.getCachedManifest())
        end)
    end)
end)
