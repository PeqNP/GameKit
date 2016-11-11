require "lang.Signal"

local Person = enum(1, 'Unknown', 'Me', 'You')

describe("switch", function()
    it("should break on first case", function()
        local case1 = false
        local case2 = false
        local case3 = false
        switch(Person.Me)
            .case(Person.Me, function()
                case1 = true
            end).b()
            .case(Person.You, function()
                case2 = true
            end).b()
            .default(function()
                case3 = true
            end)
        assert.truthy(case1)
        assert.falsy(case2)
        assert.falsy(case3)
    end)

    it("should pass-thru first case, break on second case", function()
        local case1 = false
        local case2 = false
        local case3 = false
        switch(Person.Me)
            .case(Person.Me, function()
                case1 = true
            end)
            .case(Person.You, function()
                case2 = true
            end).b()
            .default(function()
                case3 = true
            end)
        assert.truthy(case1)
        assert.truthy(case2)
        assert.falsy(case3)
    end)

    it("should pass-thru to default case", function()
        local case1 = false
        local case2 = false
        local case3 = false
        switch(Person.Unknown)
            .case(Person.Me, function()
                case1 = true
            end).b()
            .case(Person.You, function()
                case2 = true
            end).b()
            .default(function()
                case3 = true
            end)
        assert.falsy(case1)
        assert.falsy(case2)
        assert.truthy(case3)
    end)

    it("should pass-thru case 2 to default case", function()
        local case1 = false
        local case2 = false
        local case3 = false
        switch(Person.You)
            .case(Person.Me, function()
                case1 = true
            end).b()
            .case(Person.You, function()
                case2 = true
            end)
            .default(function()
                case3 = true
            end)
        assert.falsy(case1)
        assert.truthy(case2)
        assert.truthy(case3)
    end)

    it("should call case 2", function()
        local case1 = false
        local case2 = false
        local case3 = false
        switch(Person.You)
            .case(Person.Me, function()
                case1 = true
            end)
            .case(Person.You, function()
                case2 = true
            end).b()
            .default(function()
                case3 = true
            end)
        assert.falsy(case1)
        assert.truthy(case2)
        assert.falsy(case3)
    end)

    it("should break and return value for case 2", function()
        local case1 = false
        local case2 = false
        local case3 = false
        local s = switch(Person.You)
            .case(Person.Me, function()
                case1 = true
            end)
            .case(Person.You, function()
                case2 = true
                return 10 -- break isn't necessary.
            end)
            .default(function()
                case3 = true
            end)
        assert.falsy(case1)
        assert.truthy(case2)
        assert.falsy(case3)
        assert.equal(s.value(), 10)
    end)
end)
