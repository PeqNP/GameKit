require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Error)

require "HTTPResponseType"
local HTTP = require("shim.HTTP")

describe("HTTP", function()
    local subject

    before_each(function()
        subject = HTTP()
    end)
end)

describe("HTTP.getMappedResponseType", function()
    it("should return the correct Cocos2d-x type", function()
        local value = HTTP.getMappedResponseType(HTTPResponseType.String)
        assert.truthy(value)
        assert.equal(cc.XMLHTTPREQUEST_RESPONSE_STRING, value)
    end)

    it("should return the correct Cocos2d-x type", function()
        local value = HTTP.getMappedResponseType(HTTPResponseType.Blob)
        assert.truthy(value)
        assert.equal(cc.XMLHTTPREQUEST_RESPONSE_BLOB, value)
    end)

    it("should return nil", function()
        local value = HTTP.getMappedResponseType(3)
        assert.falsy(value)
    end)
end)
