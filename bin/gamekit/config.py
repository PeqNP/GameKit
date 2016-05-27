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
    print("Please configure GameKit by running the gk-path CLI tool")
    sys.exit(1)

def checkconfig(config):
    if not config.hasConfig():
        print_configure()
    if not config.project:
        print("A project must be selected first using the gk-select CLI tool")
        sys.exit(1)

def get_app_types(path):
    app_types = []
    for f in os.listdir(path):
        if "config-" in f:
            app_type = f.split("-")[1].rstrip(".json")
            app_types.append(app_type)
    return app_types

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

    def __init__(self, basepath=None, remote=None, project=None, apptype=None, androidpath=None):
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

class KeystoreConfig (object):
    def __init__(self, filepath=None, password=None, keyalias=None, keypassword=None):
        self.filepath = filepath
        self.password = password
        self.keyalias = keyalias
        self.keypassword = keypassword
        self.checkvals()

    def checkvals(self):
        for val in self.requiredvals():
            if val not in self.__dict__ or len(str(self.__dict__[val])) < 1:
                print("android.keystore configuration {} must have value for key '{}'".format(self.path, val))
                sys.exit(1)

    def requiredvals(self):
        return ["filepath", "password", "keyalias", "keypassword"]

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
        if self.android["keystore"]:
            self.keystore = KeystoreConfig(**self.android["keystore"])
        else:
            self.keystore = None

    def get_bundle(self, platform):
        if type(self.bundle) is dict:
            bundle = self.bundle.get(platform)
            if not bundle:
                raise Exception("Platform {} does not have a configured bundle ID".format(platform))
            return bundle
        return self.bundle

    def checkvals(self):
        for val in self.requiredvals():
            if val not in self.__dict__ or len(str(self.__dict__[val])) < 1:
                print("Project configuration {} must have value for key '{}'".format(self.path, val))
                sys.exit(1)
        for val in self.optionalvals():
            if val not in self.__dict__:
                print("Project configuration {} must contain key '{}'".format(self.path, val))

    def requiredvals(self):
        return ["cocos", "bundle", "name", "executable", "version", "build", "device", "orientation", "design"]

    def optionalvals(self):
        return ["hockeyappid", "facebookid", "android"]

    def save(self):
        config = self.__dict__.copy()
        config.pop("keystore")
        config.pop("path")
        config["android"]["keystore"] = self.keystore.__dict__
        fh = open(self.path, "w")
        fh.write(json.dumps(config, indent=4, separators=(',', ': '), sort_keys=True))
        fh.close()
