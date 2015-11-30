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

class Network (object):
    def __init__(self, name, ads):
        self.name = name
        self.ads = ads

class Ad (object):
    def __init__(self, _type, zoneId):
        self.type = _type
        self.zoneId = zoneId

def pods_for_networks(networks):
    pods = []
    for network in networks:
        if network.name in POD_NETWORKS.keys():
            pods.append(POD_NETWORKS[network.name])
    return pods

def load_mediation_config(source, platform):
    path = source.mediationpath(platform)
    if not os.path.isfile(path):
        raise IOError("Mediation config file for platform {} does not exist at path {}".format(platform, path))
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    config = json.loads(json_blob)
    networks = []
    for network in config:
        ads = []
        for ad in network["ads"]:
            ads.append(Ad(ad["type"], ad["zoneId"]))
        networks.append(Network(network["network"], ads))
    return networks
