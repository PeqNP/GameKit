#
# @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
#

class IAPTicket (object):
    def __init__(self, productId, sku):
        self.productId = productId
        self.sku = sku

    def toLua(self):
        return "Ticket(\"{}\", \"{}\")".format(self.productId, self.sku)

def load_iap_config(path):
    if not os.path.isfile(path):
        raise IOError("IAP config file does not exist at path {}".format(path))
    fh = open(path, "r")
    json_blob = fh.read()
    fh.close()
    tickets = []
    json_tickets = json.loads(json_blob)
    for ticket in json_tickets:
        tickets.append(IAPTicket(ticket[0], ticket[1]))
    return tickets

