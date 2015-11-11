#
# @copyright 2015 Upstart Illustration LLC. All rights reserved.
#

def gethomedir():
    from os.path import expanduser
    return expanduser("~")
