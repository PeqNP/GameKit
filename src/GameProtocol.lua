--
-- Required methods necessary to implement for a GameTools game.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local GameProtocol = Protocol(
    Method("start")
  , Method("stop")
)

return GameProtocol
