require "lang.Signal"

local ServerConfig = require("ad.ServerConfig")

describe("ServerConfig", function()
    local subject

    before_each(function()
        subject = ServerConfig("http://www.example.com", 80, "/path/to/resource")
    end)

    it("should create a full path", function()
        assert.equal("http://www.example.com:80/path/to/resource", subject.getFullPath())
    end)
end)
