--[[

  @author Eric Chamberlain
  @copyright 2014 Upstart Illustration LLC. All rights reserved.
--]]

TouchableSprite = {}
TouchableSprite.__index = TouchableSprite

setmetatable(TouchableSprite, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function TouchableSprite.new(self, _layer, _imgName, _onTouch)
    self.sprite = cc.Sprite:create(_imgName)
    _layer:addChild(self.sprite)
    self.enabled = true

    function onTouchBegan()
        if self.enabled and _onTouch then
            _onTouch()
        end
        -- Swallow all touches.
        return true
    end

    function self.clean()
        cc.Director:getInstance():getTextureCache():removeTextureForKey(_imgName)
        if not self.sprite then
            return
        end
        local parent = self.sprite:getParent()
        if parent then
            parent:removeChild(self.sprite)
        end
        self.sprite = nil
    end

    local eventDispatcher = _layer:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.sprite)
end
