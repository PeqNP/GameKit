import json
import os

# Network pod aliases
POD_NETWORKS = {
    "AdColony": "pod 'AdColony', '~> 2.6'"
  , "AdMob": "pod 'Google-Mobile-Ads-SDK', '~> 7.8'"
  , "Chartboost": "pod 'ChartboostSDK', '~> 6.0'"
  , "Leadbolt": "pod 'Leadbolt-iOS-SDK', :git => 'https://github.com/PeqNP/Leadbolt-iOS-SDK.git', :tag => '6.0.0'"
  , "Vungle": "pod 'VungleSDK-iOS', '~> 3.2'"
}
LUA_NETWORKS = {
    "AdColony": "AdColonyNetwork({appId}, {ads})"
  , "AdMob": "AdMobNetwork({ads})"
  , "Chartboost": "ChartboostNetwork({appId}, {signature}, {ads})"
  , "Leadbolt": "LeadboltNetwork({appId}, {ads})"
  , "Vungle": "VungleNetwork({appId}, {ads})"
}
LUA_AD_TYPES = {
    "Banner": "AdType.Banner"
  , "Interstitial": "AdType.Interstitial"
  , "Video": "AdType.Video"
}

def quote(val):
    if not val:
        return "nil"
    return '"' + val + '"'

class AdConfig (object):
    def __init__(self, platform, url, networks, deviceIds, automatic, orientation):
        self.platform = platform
        self.url = url
        self.networks = networks
        self.deviceIds = deviceIds
        self.automatic = automatic
        self.orientation = orientation

    def getPlatform(self):
        return self.platform

    def getUrl(self):
        return self.url

    def getNetworks(self):
        return self.networks

    def hasNetworks(self):
        return not (len(self.networks) == 0)

    def configToLua(self):
        return "AdConfig({{\"{}\"}}, {}, {})".format("\", \"".join(self.deviceIds), self.automatic and "true" or "false", self.orientation)

    def networksToLua(self, separator):
        code = []
        for network in self.networks:
            code.append(network.toLua())
        return separator.join(code)

    def getPods(self):
        pods = []
        for network in self.networks:
            if network.name in POD_NETWORKS.keys():
                pods.append(POD_NETWORKS[network.name])
        return pods

class Network (object):
    def __init__(self, name, appId, signature, ads):
        self.name = name
        self.appId = appId
        self.signature = signature
        self.ads = ads

    def toLua(self):
        ads = []
        for ad in self.ads:
            ads.append(ad.toLua())
        params = {"appId": quote(self.appId), "signature": quote(self.signature), "ads": "{" + ", ".join(ads) + "}"}
        return LUA_NETWORKS[self.name].format(**params)
    
class Ad (object):
    def __init__(self, _type, zoneId, location):
        self.type = _type
        self.zoneId = zoneId
        self.location = location

    def toLua(self):
        return "Ad({}, {}{})".format(LUA_AD_TYPES[self.type], quote(self.zoneId), self.location and ", "+str(self.location) or "")

def load_mediation_config(platform, path):
    if not os.path.isfile(path):
        raise IOError("Mediation config file does not exist at path {}".format(path))
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    config = json.loads(json_blob)
    networks = []
    for network in config["networks"]:
        ads = []
        for ad in network["ads"]:
            ads.append(Ad(ad["type"], ad["zoneId"], ad.get("location", None)))
        networks.append(Network(network["network"], network.get("appId"), network.get("signature"), ads))
    return AdConfig(platform, config.get("url", None), networks, config["config"]["devices"], config["config"]["automatic"], config["config"]["orientation"])
