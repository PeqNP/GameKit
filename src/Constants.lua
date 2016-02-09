--
-- Global constants.
--
-- @copyright (c) 2014 Upstart Illustration LLC. All rights reserved.
--

-- ----- UI / HUD -----

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

-- Locations are also used for to determine a heading. Headings do not factor in
-- the Center or Random location.
Location = enum(1
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
