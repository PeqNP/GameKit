#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

import os

# Builds Cocos2d-x realted paths.
class CocosPathBuilder (object):
    # @param Config
    # @param str - Version of Cocos
    def __init__(self, config, version):
        self.config = config
        self.version = version

    def basepath(self):
        return os.path.join(self.config.basepath, "Cocos2d-x_v{}".format(self.version))

    def path(self, path):
        return os.path.join(self.basepath(), path)

    def iosprojectpath(self):
        return self.path("frameworks/runtime-src/proj.ios_mac/GameTools.xcodeproj/project.pbxproj")

    def mediationpath(self):
        return self.path("src/game/Mediation.lua")

    def podfilepath(self):
        return self.path("frameworks/runtime-src/proj.ios_mac/Podfile")

class StagePathBuilder (object):
    def __init__(self, cocospath):
        self.cocospath = cocospath

    def basepath(self):
        return os.path.join(self.cocospath, "stage")

    def path(self, path):
        return os.path.join(self.basepath(), path)

# Builds project related paths.
class ProjectPathBuilder (object):
    # @param Config
    # @param str - project name
    def __init__(self, config):
        self.config = config

    def basepath(self):
        return os.path.join(self.config.basepath, self.config.project)

    def path(self, path):
        return os.path.join(self.basepath(), path)

    def configpath(self):
        apptype = self.config.apptype and "-{}".format(self.config.apptype) or ""
        return os.path.join(self.basepath(), "config{}.json".format(apptype))

    def apptypedir(self):
        return self.config.apptype and len(self.config.apptype) > 0 and self.config.apptype+"/" or ""

    def resourcepath(self):
        return self.path("platform/ios/res/{}Images.xcassets".format(self.apptypedir()))

    def xibpath(self):
        return self.path("platform/ios/src/LaunchScreen.xib")
    
    def mediationpath(self, platform):
        if not platform or len(platform) < 1:
            raise Exception("'platform' must be a string with a length greater than one.")
        return self.path("platform/{}/mediation.json".format(platform))
