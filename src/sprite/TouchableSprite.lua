--[[

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

TouchableSprite = Class()

function TouchableSprite.new(self)
    local imgName
    local onTouch

    self.enabled = true

    function self.init(_layer, _imgName, _onTouch)
        imgName = _imgName
        onTouch = _onTouch

        self.sprite = cc.Sprite:create(imgName)
        _layer:addChild(self.sprite)

        local eventDispatcher = _layer:getEventDispatcher()
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.sprite)
    end

    function onTouchBegan()
        if self.enabled and onTouch then
            onTouch()
        end
        -- Swallow all touches.
        return true
    end

    function self.clean()
        cc.Director:getInstance():getTextureCache():removeTextureForKey(imgName)
        if not self.sprite then
            return
        end
        local parent = self.sprite:getParent()
        if parent then
            parent:removeChild(self.sprite)
        end
        self.sprite = nil
    end
end
