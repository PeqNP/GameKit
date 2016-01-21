require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

require "Promise"

local IAP = require("iap.IAP")
local Manager = require("iap.Manager")
local Ticket = require("iap.Ticket")

describe("IAP", function()
    local subject
    local manager
    local tickets

    before_each(function()
        manager = Manager()
        tickets = {Ticket("id-10", "sku-44"), Ticket("id-104", "sku-1000")}
        subject = IAP(manager, tickets)
    end)

    it("should have tickets", function()
        assert.truthy(subject.isAvailable())
    end)

    describe("query products", function()
        local server
        local store
        local _error

        before_each(function()
            server = Promise()
            stub(manager, "fetchProducts", server)

            promise = subject.query()
            promise.done(function(_store)
                store = _store
            end)
            promise.fail(function(_e)
                _error = _e
            end)
        end)

        it("should have made call to manager", function()
            assert.stub(manager.fetchProducts).was.called_with(tickets)
        end)

        context("when the query succeeds", function()
            local response
            local invalid

            before_each(function()
                response = {}
                invalid = {}
                server.resolve(response, invalid)
            end)

            it("should have returned the store queried from the manager", function()
                assert.truthy(store)
                assert.equal(response, store)
            end)

            context("when making subsequent call to query for the store", function()
                local secondStore

                before_each(function()
                    local promise = subject.query()
                    promise.done(function(_store)
                        secondStore = _store
                    end)
                end)

                it("should immediately return the same store", function()
                    assert.truthy(secondStore)
                    assert.equal(store, secondStore)
                end)
            end)
        end)

        context("when another query is made when one is still in progress", function()
            local secondPromise
            local secondStore
            local secondError

            before_each(function()
                secondPromise = subject.query()
                secondPromise.done(function(_store)
                    secondStore = _store
                end)
                secondPromise.fail(function(_error)
                    secondError = _error
                end)
            end)

            it("should have returned the same promise", function()
                assert.truthy(secondPromise)
                assert.equal(promise, secondPromise)
            end)

            context("when the promise succeeds", function()
                local response

                before_each(function()
                    response = {}
                    server.resolve(response)
                end)

                it("should have returned the store queried from the manager", function()
                    assert.truthy(store)
                    assert.truthy(secondStore)
                    assert.equal(response, store)
                    assert.equal(response, secondStore)
                end)
            end)

            context("when the promise fails", function()
                local response

                before_each(function()
                    response = {}
                    server.reject(response)
                end)

                it("should have returned the store queried from the manager", function()
                    assert.truthy(_error)
                    assert.truthy(secondError)
                    assert.equal(response, _error)
                    assert.equal(response, secondError)
                end)

                context("when the previous request finishes", function()
                    local server2
                    local thirdResponse

                    before_each(function()
                        server2 = Promise()
                        stub(manager, "fetchProducts", server2)
                        thirdResponse = subject.query()
                    end)

                    it("should return a new response", function()
                        assert.truthy(thirdResponse)
                        assert.are_not_equal(response, thirdResponse)
                    end)
                end)
            end)
        end)

        context("when the query fails", function()
            local response

            before_each(function()
                response = {}
                server.reject(response)
            end)

            it("should have returned an error", function()
                assert.truthy(_error)
                assert.equal(response, _error)
            end)
        end)
    end)

    describe("restore purchases", function()
        local server
        local transactions
        local _error

        before_each(function()
            server = Promise()
            stub(manager, "restorePurchases", server)

            promise = subject.restorePurchases()
            promise.done(function(_transactions)
                transactions = _transactions
            end)
            promise.fail(function(_e)
                _error = _e
            end)
        end)

        context("when the process succeeds", function()
            local response

            before_each(function()
                response = {}
                server.resolve(response)
            end)

            it("should have returned transactions", function()
                assert.truthy(transactions)
                assert.equal(response, transactions)
            end)

            context("when restoring purchases when they have already been restored", function()
                local secondTransactions

                before_each(function()
                    promise = subject.restorePurchases()
                    promise.done(function(_transactions)
                        secondTransactions = _transactions
                    end)
                end)

                it("should return the original transactions", function()
                    assert.truthy(secondTransactions)
                    assert.equal(transactions, secondTransactions)
                end)
            end)
        end)

        context("when the process fails", function()
            local response

            before_each(function()
                response = {}
                server.reject(response)
            end)

            it("should return error", function()
                assert.truthy(_error)
                assert.equal(response, _error)
            end)
        end)
    end)
end)

describe("IAP when no IAP is available", function()
    local subject
    local manager

    before_each(function()
        manager = Manager()
        subject = IAP(manager, {})
    end)

    it("should NOT be available", function()
        assert.falsy(subject.isAvailable())
    end)
end)
