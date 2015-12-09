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

    describe("string.split", function()
        it("should split by delimiter", function()
            local parts = string.split("/path/to/NotificationCenter.lua", "/")
            assert.equals(3, #parts)
        end)

        it("should return full string if delimiter not found", function()
            local parts = string.split("NotificationCenter.lua", "/")
            assert.equals(1, #parts)
            assert.equals("NotificationCenter.lua", parts[1])
            assert.equals("NotificationCenter.lua", parts[#parts]) -- sanity
        end)

        it("should return everything before the period", function()
            local parts = string.split("NotificationCenter.lua", "%.")
            assert.equals("NotificationCenter", parts[1])
            assert.equals("lua", parts[2])
        end)
    end)

    describe("table.quals", function()
        it("should be equal for hashes", function()
            local t1 = {key= "value", key2= 1}
            local t2 = {key= "value", key2= 1}
            assert.truthy(table.equals(t1, t2))
        end)
        
        it("should be equal for hashes even if the values are in different positions", function()
            local t1 = {key= "value", key2= 1}
            local t2 = {key2= 1, key= "value"}
            assert.truthy(table.equals(t1, t2))
        end)

        it("should be equal for arrays that have the same values in the same position", function()
            local t1 = {"value", 1}
            local t2 = {"value", 1}
            assert.truthy(table.equals(t1, t2))
        end)

        it("should NOT be equal for arrays that have the same values but different positions", function()
            local t1 = {"value", 1}
            local t2 = {1, "value"}
            assert.falsy(table.equals(t1, t2))
        end)

        it("should be equal for tables within tables", function()
            local t1 = {"value", 1, {key="value", key2=4}}
            local t2 = {"value", 1, {key="value", key2=4}}
            assert.truthy(table.equals(t1, t2))
        end)

        it("should NOT be equal for tables within tables when the values are different", function()
            local t1 = {1, "value", {key="value", key2=4}}
            local t2 = {"value", 1, {key="value", key2=4}}
            assert.falsy(table.equals(t1, t2))
        end)

        it("should be equal with mixed tables so long as it matches Lua's internal table definition", function()
            local t1 = {key=1, "value"}
            local t2 = {"value", key=1}
            assert.truthy(table.equals(t1, t2))
        end)

        it("should NOT be equal with mixed tables whehn the values don't line up to Lua's internal table definition", function()
            local t1 = {key=1, 2, "value"}
            local t2 = {"value", 2, key=1}
            assert.falsy(table.equals(t1, t2))
        end)

        it("should NOT be equal when one table has less values", function()
            local t1 = {key=1}
            local t2 = {key=1, key=2}
            assert.falsy(table.equals(t1, t2))
        end)
    end)
end)

