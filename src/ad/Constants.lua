
AdNetwork = enum(1
  , 'Unknown'
  , 'AdColony'
  , 'AdMob'
  , 'Chartboost'
  , 'iAd'
  , 'Leadbolt'
  , 'Vungle'
)

AdType = enum(1
  , 'Unknown'
  , 'Banner'
  , 'Interstitial'
  , 'Video'
)

AdImpressionType = enum(1
  , 'Regular'
  , 'Premium'
)

AdState = enum(1
  , 'Initial'
  , 'Loading'
  , 'Ready'
  , 'Presenting'
  , 'Clicked'
  , 'Complete'
)
