require "specs.Cocos2d-x"

local AdServerConfig = require("ad.ServerConfig")
local AdServerManager = require("ad.ServerManager")
local AppManager = require("app.Manager")
local BridgeAdaptor = require("bridge.BridgeAdaptor")
local IAP = require("iap.IAP")
local SocialManager = require("social.Manager")
local RoyalAdVendor = require("royal.AdVendor")

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
        local adServer = AdServerConfig("http://www.example.com", 80, "/ad/ios/royal.json")
        local supportedVersions = {1}
        local vendor = subject.getRoyalAdVendor("/writable/path/", adServer, supportedVersions)
        assert.equal(RoyalAdVendor, vendor.getClass())
    end)
end)
