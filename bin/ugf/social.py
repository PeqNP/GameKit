import json
import os

class Config (object):
    def __init__(self, platform, networks):
        self.platform = platform
        self.networks = networks

    def getPlatform(self):
        return self.platform

    def getNetworks(self):
        return self.networks

    def hasNetworks(self):
        return not (len(self.networks) == 0)

    def networksToLua(self, separator):
        code = []
        for network in self.networks:
            code.append(network.toLua())
        return separator.join(code)

class Network (object):
    def __init__(self, name, config):
        self.name = name
        self.config = config

    def getLuaConfigDict(self):
        kvpairs = []
        print("config", self.config)
        for k, v in self.config.iteritems():
            kvpairs.append("{}=\"{}\"".format(k, v))
        return ", ".join(kvpairs)

    def toLua(self):
        # Generate 'Network([name], [config])'
        return "Network(\"{}\", {{{}}})".format(self.name, self.getLuaConfigDict())
    
def load_social_config(platform, path):
    if not os.path.isfile(path):
        #raise IOError("Social config file does not exist at path {}".format(path))
        return None
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    config = json.loads(json_blob)
    networks = []
    for network in config["networks"]:
        networks.append(Network(network["name"], network["config"]))
    return Config(platform, networks)
