--
-- Provides a way to stylize ad unit buttons before being presented.
--
-- Currently this class provides a shim between whatever framework the app is
-- using the application code. This is why you see Cococs2d-x calls here.
--
-- By default, this does _not_ stylize a button at all. It simply returns the
-- raw image as provided in the sprite frame cache.
-- 
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local shim = require("shim.System")

local AdStylizer = Class()
AdStylizer.implements("royal.AdStylizerProtocol")

function AdStylizer.new(self)
    function self.getButton(adUnit, callback)
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(adUnit.getButtonName())
        local sprite = cc.Sprite:createWithSpriteFrame(frame)
        return shim.SpriteButton(sprite, sprite, nil, callback)
    end
end

return AdStylizer
