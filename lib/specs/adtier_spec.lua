require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

require "ad.AdConfig"
require "ad.AdTier"

AdConfig.singleton.setBasePath("/path/")

describe("AdTier", function()
    local subject = false

    local id
    local url
    local reward
    local title
    local waitsecs
    local maxclicks
    local config

    before_each(function()
        stub(io, "open")
        stub(io, "input")
        stub(io, "output")
        stub(io, "read")
        stub(io, "write")
        stub(io, "close")

        id = 150
        url = "http://www.example.com/tier1"
        reward = 10
        title = "Click 1"
        waitsecs = 86400
        maxclicks = 1
        config = {1, 2, 3}
        subject = AdTier(id, url, reward, title, waitsecs, maxclicks, config)
    end)

    it("should have set all values", function()
        assert.equals(id, subject.id)
        assert.equals(url, subject.url)
        assert.equals(reward, subject.reward)
        assert.equals(title, subject.title)
        assert.equals(waitsecs, subject.waitsecs)
        assert.equals(maxclicks, subject.maxclicks)
        assert.equals(config, subject.config)
    end)

    it("should return the correct path to click file", function()
        assert.equals("/path/150.json", subject.getPath())
    end)

    it("should be active", function()
        assert.truthy(subject.isActive())
    end)

    describe("when the tier is clicked", function()
        local app

        before_each(function()
            app = cc.Application()
            stub(app, "openURL")
            stub(cc.Application, "getInstance").and_return(app)

            subject.click(8505)
        end)

        it("should have added a click", function()
            local clicks = subject.getClicks()
            assert.equals(1, #clicks)
            assert.equal(8505, clicks[1])
            assert.equal(1, subject.getNumClicks())
        end)

        it("should not be active", function()
            assert.falsy(subject.isActive())
        end)

        it("should have saved the clicks to a file", function()
            assert.stub(io.write).was.called_with("[8505]")
        end)

        it("should have sent the user to a webpage", function()
            assert.stub(app.openURL).was.called_with(app, "http://www.example.com/tier1")
        end)

        describe("click 2", function()
            before_each(function()
                subject.click(86400)
            end)

            it("should have two clicks", function()
                local clicks = subject.getClicks()
                assert.equals(2, #clicks)
                assert.equal(86400, clicks[2])
                assert.equal(2, subject.getNumClicks())
            end)

            it("should have saved the clicks to a file", function()
                assert.stub(io.write).was.called_with("[8505,86400]")
            end)
        end)
    end)

    describe("when loading tier clicks from file", function()
        local clicks
        
        describe("when there is corresponding file for ad tier config on disk", function()
            before_each(function()
                clicks = "[86555]"
                
                stub(io, "open").and_return(true)
                stub(io, "output")
                stub(io, "read").and_return(clicks)
                stub(io, "write")
                stub(io, "close")

                id = 150
                url = "http://www.example.com/tier1"
                reward = 10
                title = "Click 1"
                waitsecs = 86400
                maxclicks = 1
                config = {1, 2, 3}
                subject = AdTier(id, url, reward, title, waitsecs, maxclicks, config)
            end)

            it("should have read the clicks from the file", function()
                local c = subject.getClicks()
                assert.equals(1, #c)
                assert.equals(86555, c[1])
                assert.equals(1, subject.getNumClicks())
            end)
        end)

        describe("when there is NOT a corresponding file for ad tier config on disk", function()
            before_each(function()
                clicks = "[86555]"
                
                stub(io, "open").and_return(false)
                stub(io, "output")
                stub(io, "read").and_return(clicks)
                stub(io, "write")
                stub(io, "close")

                id = 150
                url = "http://www.example.com/tier1"
                reward = 10
                title = "Click 1"
                waitsecs = 86400
                maxclicks = 1
                config = {1, 2, 3}
                subject = AdTier(id, url, reward, title, waitsecs, maxclicks, config)
            end)

            it("should have read the clicks from the file", function()
                local c = subject.getClicks()
                assert.equals(0, #c)
            end)
        end)
    end)

    describe("button sprite frame", function()
        local cache
        local frame

        local returnedFrame

        before_each(function()
            returnedFrame = {}
            cache = cc.SpriteFrameCache:getInstance()
            stub(cache, "getSpriteFrame").and_return(returnedFrame)
        end)

        describe("button", function()
            before_each(function()
                frame = subject.getButtonSpriteFrame()
            end)

            it("should have returned a frame", function()
                assert.equals(returnedFrame, frame)
            end)

            it("should return the correct button sprite frame", function()
                assert.stub(cache.getSpriteFrame).was.called_with(cache, "button-150.png")
            end)
        end)

        describe("banner", function()
            before_each(function()
                frame = subject.getBannerSpriteFrame()
            end)

            it("should have returned a frame", function()
                assert.equals(returnedFrame, frame)
            end)

            it("should return the correct button sprite frame", function()
                assert.stub(cache.getSpriteFrame).was.called_with(cache, "banner-150.png")
            end)
        end)
    end)

    describe("button sprite frame", function()
    end)
end)
