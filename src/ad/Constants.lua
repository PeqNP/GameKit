--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

AdNetwork = enum(0
  , 'Unknown'
  , 'AdColony'
  , 'AdMob'
  , 'Chartboost'
  , 'iAd'
  , 'Leadbolt'
  , 'Vungle'
)

AdType = enum(0
  , 'Unknown'
  , 'Banner'
  , 'Interstitial'
  , 'Video'
)

AdImpressionType = enum(0
  , 'Regular'
  , 'Premium'
)

AdState = enum(0
  , 'Initial'
  , 'Loading'
  , 'Ready'
  , 'Presenting'
  , 'Clicked'
  , 'Complete'
)

AdOrientation = enum(0
  , 'AutoDetect'
  , 'Portrait'
  , 'Landscape'
)

AdLocation = enum(0
  , 'Top'
  , 'Bottom'
)
