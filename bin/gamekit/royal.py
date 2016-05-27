#
# @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
#

import json
import os

class RoyalAdNetworkConfig (object):
    def __init__(self, platform, url):
        self.platform = platform
        self.url = url

    def getPlatform(self):
        return self.platform

    def getUrl(self):
        return self.url

def load_royal_config(platform, path):
    if not os.path.isfile(path):
        raise IOError("Royal Ad Network config file does not exist at path {}".format(path))
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    config = json.loads(json_blob)
    return RoyalAdNetworkConfig(platform, config["url"])
