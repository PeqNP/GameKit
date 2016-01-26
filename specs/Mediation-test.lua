
--
-- Auto-generated by ugf-configure v1.0.0 @ 2015-12-01 16:21:59.027646
--

require "ad.Constants"
local Ad = require("ad.Ad")
local AdColonyNetwork = require("ad.network.AdColonyNetwork")
local AdMobNetwork = require("ad.network.AdMobNetwork")

local networks = {
    AdColonyNetwork("appd2f131e997a94cbbb5", {Ad(AdType.Video, "video-zone", 0)}),
    AdMobNetwork({Ad(AdType.Banner, "banner-zone", 0), Ad(AdType.Interstitial, "interstitial-zone", 0)})
}
return networks
    
