require "lang.Signal"

describe("enum", function()
    it("should create an enumeration", function()
        local e = enum(1,
            'Top'
          , 'Bottom'
        )
        assert.equal(1, e.Top)
        assert.equal(2, e.Bottom)

        assert.falsy(e.has(0))
        assert.truthy(e.has(1))
        assert.truthy(e.has(2))
        assert.falsy(e.has(3))

        assert.truthy(e.has(e.Top))
        assert.truthy(e.has(e.Bottom))

        assert.falsy(e.has(nil))
    end)

    it("should start at the correct location", function()
        local e = enum(0,
            'Top'
          , 'Bottom'
        )
        assert.equal(0, e.Top)
        assert.equal(1, e.Bottom)

        assert.falsy(e.has(-1))
        assert.truthy(e.has(0))
        assert.truthy(e.has(1))
        assert.falsy(e.has(2))

        assert.truthy(e.has(e.Top))
        assert.truthy(e.has(e.Bottom))

        assert.falsy(e.has(nil))
    end)
end)
