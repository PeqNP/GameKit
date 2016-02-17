#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

from os.path import expanduser

import os
import shutil

def getversion(path, version):
    return "%s v%s".format(os.path.basename(path), version)

def gethomedir():
    return expanduser("~")

def rmdir(path):
    if os.path.isdir(path):
        shutil.rmtree(path)

def emptydir(path):
    #import sh
    #sh.rm(sh.glob(path+"/*"))
    if (path == '/' or path == "\\"): return
    for root, dirs, files in os.walk(path, topdown=False):
        for name in files:
            os.remove(os.path.join(root, name))
        for name in dirs:
            os.rmdir(os.path.join(root, name))
