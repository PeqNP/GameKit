#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

import json

class Config (object):
    @staticmethod
    def load(path):
        fh = open(path, "r")
        json_blob = fh.read()
        fh.close()
        config = Config.configFromJson(json.loads(json_blob))
        return config

    @staticmethod
    def configFromJson(json):
        return Config(basepath=json["basepath"])

    def __init__(self, basepath=None):
        self.basepath = basepath

# Project configuration structure.
class ProjectConfig (object):
    @staticmethod
    def load(path):
        fh = open(path, "r")
        json_blob = fh.read()
        fh.close()
        config = json.loads(json_blob)
        return ProjectConfig(path, **config)

    def __init__(self, path, **entries):
        self.__dict__.update(entries)
        self.checkvals()

    def checkvals(self):
        for val in self.requiredvals():
            if val not in self.__dict__ or len(str(self.__dict__[val])) < 1:
                print("Project configuration {} must have value '{}'".format(path, val))
                sys.exit(1)
        for val in self.optionalvals():
            if val not in self.__dict__:
                print("Project configuration {} must contain key '{}'".format(path, val))

    def requiredvals(self):
        return ["cocos", "bundle", "name", "executable", "version", "build", "device", "orientation", "design"]

    def optionalvals(self):
        return ["hockeyappid", "facebookid"]
