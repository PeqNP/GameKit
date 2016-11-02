#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

import json
import os
import sys

from gamekit import gethomedir
from gamekit.buildnumber import BuildNumber

def configpath():
    return os.path.join(gethomedir(), ".gamekit")

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

    def has_app_type(self):
        return self.apptype and len(self.apptype)

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

class Vendor (object):
    def __init__(self, vendors):
        self.vendors = {}
        for key, value in vendors.items():
            self.add(key, value)

    def add(self, key, value):
        self.vendors[key] = value

    def has(self, key):
        return key in self.vendors

    def get(self, key):
        if not self.has(key):
            raise Exception("Vendor key ({}) is not registered".format(key))
        return self.vendors[key]

#
# Platform Configs
#

class PlatformConfig (object):
    def __init__(self, appid=None, version=None, executable=None, vendor=None):
        self.build = 1
        self.appid = appid
        self.version = version
        self.executable = executable
        self.vendor = Vendor(vendor)

    def get_appid(self):
        return self.appid

    def get_version(self):
        return self.version

    def get_executable(self):
        return self.executable
    
    def get_build(self):
        return self.build

class AndroidConfig (PlatformConfig):
    def __init__(self, keystore=None, **kv):
        super(AndroidConfig, self).__init__(**kv)
        if keystore:
            self.keystore = KeystoreConfig(**keystore)
        else:
            self.keystore = None

    def get_name(self):
        return "Android"

class iOSConfig (PlatformConfig):
    def get_name(self):
        return "iOS"

def load_platform_config(platform, class_ref, builder, project, config):
    c = config["platform"].get(platform)
    if "appid" not in c: c["appid"] = project.appid
    if "version" not in c: c["version"] = project.version
    inst = None
    if c:
        inst = class_ref(**c)
    else:
        inst = class_ref()
    number = BuildNumber(builder.buildnumberpath(platform))
    inst.build = number.get_value()
    return inst

class Graphics (object):
    def __init__(self, name=None, version=None):
        self.name = name
        self.version = version

# Project configuration structure.
class ProjectConfig (object):
    @staticmethod
    def load(builder):
        path = builder.configpath()
        if not os.path.isfile(path):
            raise IOError("Project config file does not exist at path {}. Does this project have an app type?".format(path))
        fh = open(path, "r")
        json_blob = fh.read()
        fh.close()
        config = json.loads(json_blob)
        project = ProjectConfig(path)
        project.__dict__.update(config)
        project.platform = {
            "ios": load_platform_config("ios", iOSConfig, builder, project, config),
            "android": load_platform_config("android", AndroidConfig, builder, project, config)
        }
        project.graphics = Graphics(**config["graphics"])
        project.checkvals()
        return project

    def __init__(self, path):
        self.path = path
        self.name = None
        self.appid = None
        self.version = None
        self.device = None
        self.orientation = None
        self.design = None
        self.platform = {}
        self.graphics = None

    def check_platform(self, platform):
        assert platform in self.platform, "Platform is not supported: {}".format(platform)

    def get_appid(self, platform):
        """
        Return a platform's configured Application ID. If not configured, return the project's
        main Application ID.

        """
        self.check_platform(platform)
        return self.platform[platform].get_appid()

    def get_version(self, platform):
        """
        Return a platform's configured version. If not configured, return the project's main version.

        """
        self.check_platform(platform)
        return self.platform[platform].version

    def get_build(self, platform):
        self.check_platform(platform)
        return self.platform[platform].get_build()

    def get_executable(self, platform):
        self.check_platform(platform)
        return self.platform[platform].get_executable()

    def has_vendor(self, platform, vendor):
        return self.get_platform(platform).vendor.has(vendor)

    def get_vendor(self, platform, vendor):
        return self.get_platform(platform).vendor.get(vendor)

    def get_platform(self, platform):
        self.check_platform(platform)
        return self.platform[platform]

    def get_platforms(self):
        return self.platform.values()

    def checkvals(self):
        for val in self.requiredvals():
            if val not in self.__dict__ or len(str(self.__dict__[val])) < 1:
                print("Project configuration {} must have value for key '{}'".format(self.path, val))
                sys.exit(1)
        for val in ["name", "version"]:
            if val not in self.graphics.__dict__:
                print("Project configuration {} must have value for 'graphics.{}'".format(self.path, val))


    def requiredvals(self):
        return ["graphics", "appid", "name", "version", "device", "orientation", "design", "platform"]

    def save(self):
        config = self.__dict__.copy()
        config.pop("path")
        config["android"]["vendor"] = config["android"]["vendor"].vendors
        config["ios"]["vendor"] = config["ios"]["ios"].vendors
        fh = open(self.path, "w")
        fh.write(json.dumps(config, indent=4, separators=(',', ': '), sort_keys=True))
        fh.close()
