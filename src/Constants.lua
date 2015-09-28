--[[
  Game constants.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

BG_MUSIC_MAX_VOL = 0.6
BG_MUSIC_MENU_VOL = 0.1
FX_MAX_VOL = 0.8

-- The z-index of the main actor.
-- @fixme This is used in Actor in the flash() method. This needs to change.
-- It was done that way to ensure the user saw the flash, even if an actor below
-- the main actor was behind it.
MAIN_ACTOR_Z = 50

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
