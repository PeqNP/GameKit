
require "lang.Signal"

describe("Signal", function()
    describe("integer.between", function()
        it("should not be between if int is < to", function()
            assert.falsy(integer.between(1, 2, 4))
        end)

        it("should not be between if int is > from", function()
            assert.falsy(integer.between(5, 2, 4))
        end)

        it("should be between if 2 and 4, if 2", function()
            assert.truthy(integer.between(2, 2, 4))
        end)

        it("should be between if 2 and 4, if 3", function()
            assert.truthy(integer.between(3, 2, 4))
        end)

        it("should be between if 2 and 4, if 4", function()
            assert.truthy(integer.between(4, 2, 4))
        end)
    end)

    describe("bit ops", function()
        it("should have bit 1", function()
            assert.truthy(hasbit(1, bit(1)))
        end)

        it("should not have bit 1", function()
            assert.falsy(hasbit(0, bit(1)))
        end)

        it("should not have bit 1", function()
            assert.falsy(hasbit(2, bit(1)))
        end)

        it("should have bit 2", function()
            assert.truthy(hasbit(2, bit(2)))
        end)

        it("should have bit 1 and 2", function()
            assert.truthy(hasbit(3, bit(1)))
            assert.truthy(hasbit(3, bit(2)))
        end)

        it("should have bit 3", function()
            assert.truthy(hasbit(4, bit(3)))
        end)

        it("should NOT have bit 3", function()
            assert.falsy(hasbit(4, bit(1)))
            assert.falsy(hasbit(4, bit(2)))
        end)
    end)

    describe("math.euclid", function()
        it("should be 5", function()
            assert.equals(5, math.euclid(100, 5))
        end)

        it("should be 5", function()
            assert.equals(5, math.euclid(5, 100))
        end)

        it("should be 1", function()
            assert.equals(1, math.euclid(7, 23))
        end)

        it("should be 25", function()
            assert.equals(25, math.euclid(25, 75))
        end)
    end)

    describe("table.euclid", function()
        it("should be 5", function()
            assert.equals(5, table.euclid({5, 100, 10}))
        end)

        it("should be 5", function()
            assert.equals(5, table.euclid({100, 5, 10}))
        end)

        it("should be 5", function()
            assert.equals(5, table.euclid({100, 5, 5, 10}))
        end)

        it("should be 7", function()
            assert.equals(7, math.euclid(14, 7, 21))
        end)

        it("should be 5", function()
            assert.equals(25, table.euclid({25, 75}))
        end)
    end)
end)
