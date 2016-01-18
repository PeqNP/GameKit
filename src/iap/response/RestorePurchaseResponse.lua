--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Transaction = require("iap.Transaction")

local RestorePurchaseResponse = Class()

function RestorePurchaseResponse.new(self)
    local id
    local transactions

    local function getTransactions(_transactions)
        if not _transactions or _transactions == "" then
            return {}
        end
        local transactions = string.split(_transactions, ",")
        local parsed = {}
        for _, transaction in ipairs(transactions) do
            local parts = string.split(transaction, ":")
            -- @note Transaction params: SKU, Receipt
            table.insert(parsed, Transaction(parts[1], parts[2]))
        end
        return parsed
    end

    function self.init(_id, _transactions)
        id = _id
        transactions = getTransactions(_transactions)
    end

    function self.getTransactions()
        return transactions
    end
end

return RestorePurchaseResponse
