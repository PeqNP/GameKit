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
        return os.path.join(self.basepath(), "frameworks/runtime-src/proj.ios_mac/GameTools.xcodeproj/project.pbxproj")

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
        return os.path.join(self.basepath(), "config.json")

    def resdir(self):
        return self.config.resource and len(self.config.resource) > 0 and self.config.resource+"/" or ""

    def resourcepath(self):
        return self.path("platform/ios/res/{}Images.xcassets".format(self.resdir()))

    def xibpath(self):
        return self.path("platform/ios/src/LaunchScreen.xib")
