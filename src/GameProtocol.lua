--
-- Required protocol for games made with GameKit. Specifically, this protocol must always
-- be implemented on the main 'Game' module.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local GameProtocol = Protocol(
    Method("start")
  , Method("stop")
)

return GameProtocol
