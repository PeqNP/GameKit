--[[
  Provides a simple type setter.

  This class provides an easy way to associate characters to a glyph sprite
  sheet. It also provides routines to turn glyphs into a single sprite.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

require "Glyph"

TypeSetter = Class()

function TypeSetter.new(self, _sheet, _data, _kerning)
    local _glyphs = {}

    local function initialize()
        local numLetters = #_data
        local frames = _sheet.getFrames()
        for i = 1, #_data do
            local char, width
            -- hmmm... seems like there should be a better way to do this.
            for k, v in pairs(_data[i]) do
                char, width = k, v
            end
            _glyphs[ string.byte(char) ] = Glyph(char, width, frames[i])
        end
        _data = nil -- No longer needed.
    end

    --[[
      Layout 'text' glyphs into a layer.

      @param text The text to convert to glyphs
      @param z The z-index of the letters.
      @return Layer that contains the laid out glyphs
    --]]
    function self.getLayout(text, z)
        local layout = cc.Sprite:create()
        local x = 0
        for char in text:gmatch(".") do
            local glyph = _glyphs[ string.byte(char) ]
            if glyph then
                local sprite = cc.Sprite:createWithSpriteFrame(glyph.frame.sprite)
                sprite:setPosition(x, _sheet.height/2)
                sprite:setGlobalZOrder(z)
                x = x + glyph.width + _kerning -- Determine next position to set the letter.
                layout:addChild(sprite)
            end
        end
        return layout
    end

    initialize()
end
