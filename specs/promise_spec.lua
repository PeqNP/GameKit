require "lang.Signal"

local Promise = require("Promise" )

describe("resolve", function()
	it("should pass in the accepted value", function()
		local val, test = 'pizza'
		local p = Promise()
		p.done(function(x) test = x end)
        assert.falsy(p.isComplete())
		p.resolve(val)
		assert.equals(val, test)
        assert.equal("resolved", p.getState())
        assert.truthy(p.isComplete())
	end)

	it("should directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise()
        assert.falsy(p.isComplete())
		p.resolve(val)
		p.done(function(x) test = x end)
		assert.equals(val, test)
        assert.equal("resolved", p.getState())
        assert.truthy(p.isComplete())
	end)
end)

describe("reject", function()
	it("should pass in the accepted value", function()
		local val, test = 'pizza'
		local p = Promise()
        assert.falsy(p.isComplete())
		p.fail(function(x) test = x end)
		p.reject(val)
		assert.equals(val, test)
        assert.equal("rejected", p.getState())
        assert.truthy(p.isComplete())
	end)

	it("should directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise()
        assert.falsy(p.isComplete())
		p.reject(val)
		p.fail(function(x) test = x end)
		assert.equals(val, test)
        assert.equal("rejected", p.getState())
        assert.truthy(p.isComplete())
	end)
end)

describe("always", function()
	it("should fire a callback if resolved", function()
		local val, test = 'pizza'
		local p = Promise()
		p.always(function(x) test = x end)
		p.resolve(val)
		assert.equals(val, test)
	end)

	it("should fire a callback if rejected", function()
		local val, test = 'pizza'
		local p = Promise()
		p.always(function(x) test = x end)
		p.reject(val)
		assert.equals(val, test)
	end)

	it("should directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise()
		p.resolve(val)
		p.always(function(x) test = x end)
		assert.equals(val, test)
	end)

	it("should directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise()
		p.reject(val)
		p.always(function(x) test = x end)
		assert.equals(val, test)
	end)
end)

describe("done", function()
	it("should fire a callback if resolved", function()
		local val, test = 'pizza'
		local p = Promise()
		p.done(function(x) test = x end)
		p.resolve(val)
		assert.equals(val, test)
	end)

	it("should not fire a callback if rejected", function()
		local val, test = 'pizza'
		local p = Promise()
		p.done(function(x) test = x end)
		p.reject(val)
		assert.equals(test, nil)
	end)

	it("should directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise()
		p.resolve(val)
		p.done(function(x) test = x end)
		assert.equals(val, test)
	end)

	it("should not directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise()
		p.reject(val)
		p.done(function(x) test = x end)
		assert.equals(test, nil)
	end)
end)

describe("fail", function()
	it("should not fire a callback if resolved", function()
		local val, test = 'pizza'
		local p = Promise()
		p.fail(function(x) test = x end)
		p.resolve(val)
		assert.equals(test, nil)
	end)

	it("should fire a callback if rejected", function()
		local val, test = 'pizza'
		local p = Promise()
		p.fail(function(x) test = x end)
		p.reject(val)
		assert.equals(test, val)
	end)

	it("should not directly call callback if it is already resolved", function()
		local val, test = 'pizza'
		local p = Promise()
		p.resolve(val)
		p.fail(function(x) test = x end)
		assert.equals(test, nil)
	end)

	it("should directly call callback if it is already rejected", function()
		local val, test = 'pizza'
		local p = Promise()
		p.reject(val)
		p.fail(function(x) test = x end)
		assert.equals(test, val)
	end)

end)

describe("notify", function()
	it("should update progress subscribers", function()
		local p = Promise()
		local count = 0
		p.progress(function(x) count = count + x end)
		p.notify(1)
		p.notify(2)
		assert.equals(count, 3)
	end)
end)

describe("when", function()
	it("should return a promise", function()
		local promise = Promise.when()
        assert.equal(Promise, promise.getClass())
	end)

	it("should resolve when all promises are met", function()
		local p1 = Promise()
		local p2 = Promise()
		local y1, y2

		Promise.when(p1, p2).done(function(x1, x2)
			y1 = x1
			y2 = x2
		end)

		p1.resolve(1)
		p2.resolve(2)

		assert.equals(y1, 1)
		assert.equals(y2, 2)
	end)

	it("should reject if any of the promises are broken", function()
		local p1 = Promise()
		local p2 = Promise()
		local y1, y2

		Promise.when(p1, p2).fail(function(x1, x2)
			y1 = x1
			y2 = x2
		end)

		p1.resolve(1)
		p2.reject(2)

		assert.equals(y1, 1)
		assert.equals(y2, 2)
	end)

	it("should handle non deferred values", function()
		local p1 = 1
		local p2 = Promise()
		local y1, y2

		Promise.when(p1, p2).fail(function(x1, x2)
			y1 = x1
			y2 = x2
		end)

		p2.reject(2)

		assert.equals(y1, 1)
		assert.equals(y2, 2)
	end)
end)
