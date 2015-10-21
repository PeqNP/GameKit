--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

AdModuleProtocol = Protocol(
    -- Return config used to initialize network module.
    Method("getConfig", true)
    -- Returns the ad network ID used by this module.
  , Method("getAdNetwork", true)
    -- Returns the name of the ad network used by this module.
  , Method("getAdNetworkName", true)
    -- Returns the AdType
  , Method("getAdType", true)
    -- Generates a request struct that can be marshalled between Lua and native land.
  , Method("generateAdRequest", true)
)
