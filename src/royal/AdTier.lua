--[[ Provides an Ad tier, a structure that provides a reward and metadata for
     an ad; which is used to determine when to display the given tier.

 @since 2015.05.27
 @copyright Upstart Illustration LLC

--]]

require "json"

require "royal.AdConfig"

AdTier = Class()

function AdTier.new(self)
    -- Clicks this ad has received.
    local clicks = {}

    local function init()
        local fh = io.open(self.getPath(), "r")
        if not fh then
            return
        end
        io.input(fh)
        local jsonStr = io.read()
        io.close(fh)
        -- What if there is no file?
        -- What if there are no contents in the file?
        if jsonStr and string.len(jsonStr) > 0 then
            clicks = json.decode(jsonStr)
        end
    end

    function self.init(id, url, reward, title, waitsecs, maxclicks, config)
        self.id = id
        self.url = url
        self.reward = reward
        self.title = title
        self.waitsecs = waitsecs
        self.maxclicks = maxclicks
        self.config = config

        init()
    end

    function self.getButtonName()
        return "button-" .. tostring(self.id) .. ".png"
    end

    function self.getBannerName()
        return "banner-" .. tostring(self.id) .. ".png"
    end

    function self.getButtonSpriteFrame()
        return cc.SpriteFrameCache:getInstance():getSpriteFrame(self.getButtonName())
    end

    function self.getBannerSpriteFrame()
        return cc.SpriteFrameCache:getInstance():getSpriteFrame(self.getBannerName())
    end

    function self.getButtonSprite()
        return cc.Sprite:createWithSpriteFrame(self.getButtonSpriteFrame())
    end

    function self.getPath()
        return AdConfig.singleton.getPath(tostring(self.id) .. ".json")
    end

    function self.click(ts)
        --Log.i("AdTier id (%s) clicked on (%s)", self.id, ts)
        table.insert(clicks, ts)

        local jstr = json.encode(clicks)
        local fh = io.open(self.getPath(), "w")
        io.output(fh)
        io.write(jstr)
        io.close(fh)

        -- @fixme Does this logic belong here?
        cc.Application:getInstance():openURL(self.url)
    end

    function self.getClicks()
        return clicks
    end

    function self.getNumClicks()
        return #clicks
    end

    --[[ Returns whether this tier is active; which can be used to determine if
         it is displayed or not. ]]--
    function self.isActive()
        return #clicks < self.maxclicks
    end
end
