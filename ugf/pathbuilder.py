#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

import os

# Builds Cocos2d-x realted paths.
class CocosPathBuilder (object):
    # @param Config
    # @param ProjectConfig
    # @param SelectOptions
    def __init__(self, config, project, options):
        self.config = config
        self.project = project
        self.options = options

    def basepath(self):
        return os.path.join(self.config.basepath, "Cocos2d-x_v{}".format(self.project.cocos))

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
    # @param SelectOptions
    def __init__(self, config, projectname, options):
        self.config = config
        self.projectname = projectname
        self.options = options

    def basepath(self):
        return os.path.join(self.config.basepath, self.projectname)

    def path(self, path):
        return os.path.join(self.basepath(), path)

    def configpath(self):
        return os.path.join(self.basepath(), "config.json")

    def resdir(self):
        return self.options.resource and len(self.options.resource) > 0 and self.options.resource+"/" or ""

    def resourcepath(self):
        return os.path.join(self.basepath(), "platform/ios/{}res/Images.xcassets".format(self.resdir()))
