#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

import json
import os
import sys

from ugf import gethomedir

def configpath():
    return os.path.join(gethomedir(), ".ugf")

def print_configure():
    print("Please configure the UGF utility by running the gk-path CLI tool")
    sys.exit(1)

def checkconfig(config):
    if not config.hasConfig():
        print_configure()
    if not config.project:
        print("A project must be selected first using the gk-select CLI tool")
        sys.exit(1)

class Config (object):
    @staticmethod
    def load(path, project=None, apptype=None):
        if not os.path.exists(path):
            print_configure()
        fh = open(path, "r")
        json_blob = fh.read()
        fh.close()
        json_dict = json.loads(json_blob)
        if project:
            json_dict["project"] = project
        if apptype is not None:
            json_dict["apptype"] = apptype
        config = Config.configFromJson(json_dict)
        return config

    @staticmethod
    def configFromJson(json):
        project = "project" in json and json["project"] or None
        apptype = "apptype" in json and json["apptype"] or None
        return Config(json.get("basepath", None), json.get("remote", None), project, apptype, json.get("androidpath", None))

    def __init__(self, basepath, remote, project, apptype, androidpath):
        self.basepath = basepath
        self.remote = remote
        self.project = project
        self.apptype = apptype
        self.androidpath = androidpath

    def hasConfig(self):
        return self.basepath and self.remote

    def save(self, path):
        json_blob = json.dumps(self.__dict__)
        fh = open(path, "w")
        fh.write(json_blob)
        fh.close()
    
    def giturl(self, name):
        remote = self.remote.rstrip("/")
        return "{}/{}.git".format(self.remote, name)

    def path(self, path):
        return os.path.join(self.basepath, path)

# Project configuration structure.
class ProjectConfig (object):
    @staticmethod
    def load(path):
        if not os.path.isfile(path):
            raise IOError("Project config file does not exist at path {}. Does this project have an app type?".format(path))
        fh = open(path, "r")
        json_blob = fh.read()
        fh.close()
        config = json.loads(json_blob)
        return ProjectConfig(path, **config)

    def __init__(self, path, **entries):
        self.path = path
        self.__dict__.update(entries)
        self.checkvals()

    def getBundle(self, platform):
        if type(self.bundle) is dict:
            bundle = self.bundle.get(platform)
            if not bundle:
                raise Exception("Platform {} does not have a configured bundle ID".format(platform))
            return bundle
        return self.bundle

    def checkvals(self):
        for val in self.requiredvals():
            if val not in self.__dict__ or len(str(self.__dict__[val])) < 1:
                print("Project configuration {} must have value '{}'".format(self.path, val))
                sys.exit(1)
        for val in self.optionalvals():
            if val not in self.__dict__:
                print("Project configuration {} must contain key '{}'".format(self.path, val))

    def requiredvals(self):
        return ["cocos", "bundle", "name", "executable", "version", "build", "device", "orientation", "design"]

    def optionalvals(self):
        return ["hockeyappid", "facebookid"]
