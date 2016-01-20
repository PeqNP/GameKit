--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Promise"

local IAP = Class()

function IAP.new(self)
    local manager
    local tickets
    local store
    local transactions

    function self.init(_manager, _tickets)
        manager = _manager
        tickets = _tickets
    end

    function self.isAvailable()
        return #tickets > 0
    end

    function self.query()
        local deferred = Promise()
        if store then
            deferred.resolve(store)
            return deferred
        end
        local promise = manager.fetchProducts(_tickets)
        promise.done(function(_store, _invalid)
            store = _store
            deferred.resolve(store)
        end)
        promise.fail(function(_error)
            deferred.reject(_error)
        end)
        return deferred
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
