#
# @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
#

class RoyalAdNetworkConfig (object):
    def __init__(self, url):
        self.url = url

    def getURL(self):
        return self.url

def load_royal_config(path):
    if not os.path.isfile(path):
        raise IOError("Royal Ad Network config file does not exist at path {}".format(path))
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    config = json.loads(json_blob)
    return RoyalAdNetworkConfig(config["url"])
