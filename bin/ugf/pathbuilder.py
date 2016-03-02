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

    def foldername(self):
        return "Cocos2d-x_v{}".format(self.version)

    def basepath(self):
        return os.path.join(self.config.basepath, self.foldername())

    def path(self, path):
        return os.path.join(self.basepath(), path)

    def iosmacprojpath(self, path=None):
        iosmacprojpath = self.path("frameworks/runtime-src/proj.ios_mac") 
        if path:
            return os.path.join(iosmacprojpath, path)
        return iosmacprojpath

    def androidprojpath(self, path=None):
        androidprojpath = self.path("frameworks/runtime-src/proj.android") 
        if path:
            return os.path.join(androidprojpath, path)
        return androidprojpath

    def iosprojectpath(self):
        return self.path("frameworks/runtime-src/proj.ios_mac/GameTools.xcodeproj/project.pbxproj")

    def mediationluapath(self, platform):
        return self.path("src/Mediation-{}.lua".format(platform))

    def mediationconfigpath(self, platform):
        return self.path("res/mediation-{}.config.json".format(platform))

    def iapluapath(self, platform):
        return self.path("src/IAP-{}.lua".format(platform))

    def royalluapath(self, platform):
        return self.path("src/Royal-{}.lua".format(platform))

    def podfilepath(self):
        return self.iosmacprojpath("Podfile")

class StagePathBuilder (object):
    def __init__(self, cocospath):
        self.cocospath = cocospath

    def basepath(self):
        return os.path.join(self.cocospath, "stage")

    def path(self, path):
        return os.path.join(self.basepath(), path)

class GameKitPathBuilder (object):
    def __init__(self, config):
        self.config = config

    def basepath(self):
        return os.path.join(self.config.basepath, "GameKit")

    def path(self, path):
        return os.path.join(self.basepath(), path)

    def templatepath(self):
        return self.path("template")

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

    def resourcepath(self, platform, resource):
        self.check_platform(platform)
        return self.path("platform/{}/res/{}{}".format(platform, self.apptypedir(), resource))

    def xibpath(self):
        return self.path("platform/ios/src/LaunchScreen.xib")

    def check_platform(self, platform):
        if not platform or len(platform) < 1:
            raise Exception("'platform' must be a string with a length greater than one.")
    
    def mediationpath(self, platform):
        self.check_platform(platform)
        return self.path("platform/{}/mediation.server.json".format(platform))

    def iappath(self, platform):
        self.check_platform(platform)
        return self.path("platform/{}/iap.json".format(platform))

    def royalpath(self, platform):
        self.check_platform(platform)
        return self.path("platform/{}/royal.server.json".format(platform))

    def mediationconfigpath(self, platform):
        self.check_platform(platform)
        return self.path("platform/{}/mediation.config.json".format(platform))

class iOS_GameKitPathBuilder (object):
    # @param Config
    # @param str - project name
    def __init__(self, config):
        self.config = config

    def basepath(self):
        return os.path.join(self.config.basepath, "GameKit-iOS")

    def path(self, path):
        return os.path.join(self.basepath(), path)

    def sourcedir(self):
        return self.path("AdKit")

class Android_GameKitPathBuilder (object):
    # @param Config
    # @param str - project name
    def __init__(self, config):
        self.config = config

    def basepath(self):
        return os.path.join(self.config.basepath, "GameKit-Android")

    def path(self, path):
        return os.path.join(self.basepath(), path)

    def sourcedir(self):
        return self.path("app/src/main/java/com/upstartillustration")

class DependenciesPathBuilder (object):
    def __init__(self, config):
        self.config = config

    def basepath(self):
        return os.path.join(self.config.basepath, "GameKit-dependencies")

    def path(self, path):
        return os.path.join(self.basepath(), path)
