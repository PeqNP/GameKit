#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

import json
import os
import sys

from ugf import gethomedir

def configpath():
    return os.path.join(gethomedir(), ".ugf")

def checkconfig(config):
    if not config.basepath:
        print("The basepath must be configured using the ugf-config CLI tool")
        sys.exit(1)
    if not config.project:
        print("A project must be selected first using the ugf-select CLI tool")
        sys.exit(1)

class Config (object):
    @staticmethod
    def load(path, project=None, resource=None):
        fh = open(path, "r")
        json_blob = fh.read()
        fh.close()
        json_dict = json.loads(json_blob)
        if project:
            json_dict["project"] = project
        if resource:
            json_dict["resource"] = resource
        config = Config.configFromJson(json_dict)
        return config

    @staticmethod
    def configFromJson(json):
        project = "project" in json and json["project"] or None
        resource = "resource" in json and json["resource"] or None
        return Config(json["basepath"], project, resource)

    def __init__(self, basepath, project, resource):
        self.basepath = basepath
        self.project = project
        self.resource = resource

    def save(self, path):
        json_blob = json.dumps(self.__dict__)
        fh = open(path, "w")
        fh.write(json_blob)
        fh.close()

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
