--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local AdStylizerProtocol = Protocol(
    -- Returns a stylized button.
    -- @param AdUnit
    -- @param LuaFn - Callback to execute when button is pressed.
    Method("getButton")
)
return AdStylizerProtocol
