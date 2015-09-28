--[[
  Provides data structure for a letter glyph; which is used by the TypeSetter.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

Glyph = Class()

function Glyph.new(_char, _width, _frame)
    local self = {}

    self.char = _char
    self.width = _width
    self.frame = _frame
    
    return self
end
