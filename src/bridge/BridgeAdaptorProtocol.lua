--
-- @copyright (c) 2016 Upstat Illustration LLC. All rights reserved.
--

local BridgeAdaptorProtocol = Protocol(
    -- 'Send' the method to the native platform.
    -- FIXME: This is a horrible method name. Rename to 'call' in the future.
    Method("send")
)

return BridgeAdaptorProtocol
