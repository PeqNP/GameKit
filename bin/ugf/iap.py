#
# @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
#

import json
import os

class IAPConfig (object):
    def __init__(self, platform, tickets):
        self.platform = platform
        self.tickets = tickets

    def getPlatform(self):
        return self.platform

    def ticketsToLua(self, separator):
        lua_tickets = []
        for ticket in self.tickets:
            lua_tickets.append(ticket.toLua())
        return separator.join(lua_tickets)

class IAPTicket (object):
    def __init__(self, productId, sku):
        self.productId = productId
        self.sku = sku

    def toLua(self):
        return "Ticket(\"{}\", \"{}\")".format(self.productId, self.sku)

def load_iap_config(platform, path):
    if not os.path.isfile(path):
        raise IOError("IAP config file does not exist at path {}".format(path))
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    tickets = []
    json_tickets = json.loads(json_blob)
    for ticket in json_tickets:
        tickets.append(IAPTicket(ticket[0], ticket[1]))
    return IAPConfig(platform, tickets)

