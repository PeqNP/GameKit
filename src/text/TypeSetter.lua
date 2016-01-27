--
-- Provides a simple type setter.
--
-- This class provides an easy way to associate characters to a glyph sprite
-- sheet. It also provides routines to turn glyphs into a single sprite.
--
--  @copyright 2014 Upstart Illustration LLC. All rights reserved.
--

local Glyph = require("text.Glyph")

local TypeSetter = Class()

function TypeSetter.new(self)
    local sheet
    local data
    local kerning

    local _glyphs = {}

    local function createGlyphs()
        local numLetters = #data
        local frames = sheet.getFrames()
        for i = 1, #data do
            local char, width
            -- hmmm... seems like there should be a better way to do this.
            for k, v in pairs(data[i]) do
                char, width = k, v
            end
            _glyphs[ string.byte(char) ] = Glyph(char, width, frames[i])
        end
        data = nil -- No longer needed.
    end

    function self.init(_sheet, _data, _kerning)
        sheet = _sheet
        data = _data
        kerning = _kerning

        createGlyphs()
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
                sprite:setPosition(x, sheet.height/2)
                sprite:setGlobalZOrder(z)
                x = x + glyph.width + kerning -- Determine next position to set the letter.
                layout:addChild(sprite)
            end
        end
        return layout
    end
end

return TypeSetter
