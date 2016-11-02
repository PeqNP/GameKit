#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

import os
import re
import shutil

class Interpolator (object):
    # @param PathBuilder
    # @param IGraphicsPathBuilder
    # @param StagePathBuilder
    # @param dict - contains key/values to interpolate within template
    def __init__(self, project, cocos, stage, keys):
        self.project = project
        self.cocos = cocos
        self.stage = stage
        self.keys = keys

    # @param template - template file that will be interpolated
    # @param target - target path where template will be copied to after interpolation
    # @param func - Function that provides additional interpolation rules
    def interpolate(self, template, target=None, interpolator=None):
        # Read
        fh = open(self.cocos.path(template), "r")
        blob = fh.read()
        for key, val in self.keys.iteritems():
            blob = re.sub(key, str(val), blob)
        if interpolator:
            blob = interpolator(self.project, blob)
        fh.close()
        # Write
        stagepath = self.stage.path(os.path.split(template)[1])
        fh = open(stagepath, "w")
        fh.write(blob)
        fh.close()
        if not target:
            return blob
        # Copy to target location.
        shutil.copyfile(stagepath, self.cocos.path(target))

class SimpleInterpolator (object):
    def __init__(self, keys):
        self.keys = keys

    def interpolate(self, source, destination, interpolator=None):
        # Read
        fh = open(source, "r")
        blob = fh.read()
        for key, val in self.keys.iteritems():
            blob = re.sub(key, str(val), blob)
        if interpolator:
            blob = interpolator(blob)
        fh.close()
        # Write
        fh = open(destination, "w")
        fh.write(blob)
        fh.close()
