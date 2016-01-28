require "lang.Signal"

local Logger = require("Logger")

describe("Logger", function()
    local subject

    describe("default level", function()
        before_each(function()
            subject = Logger()
        end)

        it("should have set the Debug as default level", function()
            assert.equals(LogLevel.Debug, subject.getLevel())
        end)
    end)

    describe("given level", function()
        before_each(function()
            subject = Logger(LogLevel.Info)
        end)

        it("should have set the log level to Info", function()
            assert.equals(LogLevel.Info, subject.getLevel())
        end)
    end)
end)

describe("Log", function()
    it("should have created a global 'Log' variable", function()
        assert.truthy(Log)
    end)
end)
