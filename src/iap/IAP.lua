--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Logger"
require "Promise"

local IAP = Class()

function IAP.new(self)
    local manager
    local tickets
    local store
    local transactions
    local qDeferred

    function self.init(_manager, _tickets)
        manager = _manager
        tickets = _tickets
    end

    function self.isAvailable()
        return #tickets > 0
    end

    function self.query()
        if qDeferred then
            Log.i("IAP:query() - piggy backing on previous request")
            return qDeferred
        end
        qDeferred = Promise()
        if store then
            qDeferred.resolve(store)
            return qDeferred
        end
        local promise = manager.fetchProducts(tickets)
        promise.done(function(_store, _invalid)
            store = _store
            qDeferred.resolve(store)
            qDeferred = nil
        end)
        promise.fail(function(_error)
            qDeferred.reject(_error)
            qDeferred = nil
        end)
        return qDeferred
    end

    function self.restorePurchases()
        local deferred = Promise()
        if transactions then
            deferred.resolve(transactions)
            return deferred
        end
        local promise = manager.restorePurchases()
        promise.done(function(_transactions)
            transactions = _transactions
            deferred.resolve(transactions)
        end)
        promise.fail(function(_error)
            deferred.reject(_error)
        end)
        return deferred
    end
end

return IAP
