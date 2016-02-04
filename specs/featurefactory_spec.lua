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

    it("should create a royal.Manager", function()
        local vendor = subject.getRoyalClient("/writable/path/", "http://www.example.com:80/ad/ios/")
        assert.equal(RoyalClient, vendor.getClass())
    end)
end)
