#
# @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
#

import os

class BuildNumber (object):
    def __init__(self, path):
        self.path = path
        self.value = self.load_value()

    def load_value(self):
        """
        Load the current build # value from file.

        Do not call this value directly. This is used by the initializer to obtain
        current value.

        """
        # Return default value of '0' if file doesn't exist.
        if not os.path.isfile(self.path):
            return 0
        # Read value from file.
        value = 0
        with open(self.path, "r") as fh:
            value = int(fh.read().strip())
        return value
    
    def get_value(self):
        return self.value

    def increment(self, amount):
        self.value = self.value + amount

    def save(self):
        with open(self.path, "w") as fh:
            fh.write(str(self.value))
