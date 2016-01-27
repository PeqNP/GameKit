--
-- Provides data structure for a letter glyph; which is used by the TypeSetter.
--
-- @copyright (c) 2014 Upstart Illustration LLC. All rights reserved.
--

local Glyph = Class()

function Glyph.new(self)
    function self.init(char, width, frame)
        self.char = char
        self.width = width
        self.frame = frame
    end
end

return Glyph
