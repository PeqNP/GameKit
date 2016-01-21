import json
import os

# Network pod aliases
POD_NETWORKS = {
    "AdColony": "pod 'AdColony', '~> 2.6'"
  , "AdMob": "pod 'Google-Mobile-Ads-SDK', '~> 7.0'"
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

class AdServerConfig (object):
    def __init__(self, host, port, path):
        self.host = host
        self.port = port
        self.path = path

    def toLua(self):
        if self.host:
            return "AdServerConfig(\"{}\", {}, \"{}\")".format(self.host, self.port, self.path)
        return "nil"

class AdConfig (object):
    def __init__(self, deviceIds, automatic, orientation):
        self.deviceIds = deviceIds
        self.automatic = automatic
        self.orientation = orientation

    def toLua(self):
        return "AdConfig({{\"{}\"}}, {}, {})".format("\", \"".join(self.deviceIds), self.automatic and "true" or "false", self.orientation)

class IAPTicket (object):
    def __init__(self, productId, sku):
        self.productId = productId
        self.sku = sku

    def toLua(self):
        return "Ticket(\"{}\", \"{}\")".format(self.productId, self.sku)

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

def pods_for_networks(networks):
    pods = []
    for network in networks:
        if network.name in POD_NETWORKS.keys():
            pods.append(POD_NETWORKS[network.name])
    return pods

def load_mediation_config(path):
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
    server = config.get("server", None)
    if server:
        server = AdServerConfig(server["host"], server["port"], server["path"])
    return AdConfig(config["config"]["devices"], config["config"]["automatic"], config["config"]["orientation"]), networks, server

def load_iap_config(path):
    if not os.path.isfile(path):
        raise IOError("IAP config file does not exist at path {}".format(path))
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    tickets = []
    json_tickets = json.loads(json_blob)
    for ticket in json_tickets:
        tickets.append(IAPTicket(ticket[0], ticket[1]))
    return tickets

def lua_for_networks(networks):
    code = []
    for network in networks:
        code.append(network.toLua())
    return code
