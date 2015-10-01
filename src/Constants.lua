--[[
  Global constants.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

--[[ UI / HUD ]]--

Touch = enum(1
  , 'Began'
  , 'Moved'
  , 'Ended'
)

Direction = bitmask(0x01
  , 'Up'
  , 'Down'
  , 'Left'
  , 'Right'
)

Heading = enum(1
  , 'TopLeft'
  , 'Top'
  , 'TopRight'
  , 'Right'
  , 'BottomRight'
  , 'Bottom'
  , 'BottomLeft'
  , 'Left'
  , 'Center'
  , 'Random'
)
