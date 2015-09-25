--[[ Provides FadingText behaviour.

@todo Make font, font size and alignment passed through to initializer.

@author Eric Chamberlain
@copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

FadingText = Class()

function FadingText.new(_layer, _text)
    local self = {}

    local _label

    local function initialize()
        local size = getVisibleSize()
        local lbl = cc.LabelBMFont:create(_text, "SilverAgeLCBB.fnt", 500, cc.TEXT_ALIGNMENT_LEFT)
        local bbox = lbl:getBoundingBox()
        lbl:setPosition(bbox.width/2, bbox.height/2)

        local lblSize = lbl:getContentSize()
        local texture = cc.RenderTexture:create(lblSize.width, lblSize.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
        texture:begin()
        texture:addChild(lbl)
        lbl:visit()
        texture:endToLua()
        _label = cc.Sprite:createWithTexture(texture:getSprite():getTexture())
        local bbox = _label:getBoundingBox()
        _label:setScale(0.5)
        _label:setPosition((size.width/2), size.height-100)
        _label:setOpacity(0.0)
        _label:setFlippedY(true)
        _label:setGlobalZOrder(50)
        _layer:addChild(_label)
    end

    function self.start()
        local function fadeOut()
            _label:runAction(cc.Sequence:create(
                cc.FadeOut:create(1.5)
              , cc.DelayTime:create(0.25)
              , cc.CallFunc:create(self.start)
            ))
        end
        local function fadeIn()
            _label:runAction(cc.Sequence:create(
                cc.FadeIn:create(1.5)
              , cc.DelayTime:create(0.25)
              , cc.CallFunc:create(fadeOut)
            ))
        end
        fadeIn()
    end

    function self.stop()
        _label:stopAllActions()
        local parent = _label:getParent()
        parent:removeChild(_label)
    end

    initialize()

    return self
end
