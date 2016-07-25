require "lang.Signal"

local Logger = require("Logger")

describe("Log", function()
    it("should have created a global 'Log' variable", function()
        assert.truthy(Log)
    end)
end)

describe("Logger", function()
    local subject

    describe("default level", function()
        before_each(function()
            subject = Logger()
            stub(Logger, "pipe")
        end)

        it("should have set the Debug as default level", function()
            assert.equals(LogLevel.Debug, subject.getLevel())
        end)

        it("should emit debug log", function()
            subject.d("Debug message with param %s", 2)
            assert.stub(Logger.pipe).was.called_with("D: Debug message with param 2")
        end)

        it("should emit info log", function()
            subject.i("Info message with param %s", 2)
            assert.stub(Logger.pipe).was.called_with("I: Info message with param 2")
        end)

        it("should emit warning log", function()
            subject.w("Warning message with param %s", 2)
            assert.stub(Logger.pipe).was.called_with("W: Warning message with param 2")
        end)

        it("should emit error log", function()
            subject.e("Error message with param %s", 2)
            assert.stub(Logger.pipe).was.called_with("E: Error message with param 2")
        end)

        it("should emit sever log", function()
            subject.s("Severe message with param %s", 2)
            assert.stub(Logger.pipe).was.called_with("S: Severe message with param 2")
        end)

        context("when sending an empty message", function()
            before_each(function()
                subject.d(nil, 1)
            end)

            it("should have sent an error message", function()
                assert.stub(Logger.pipe).was.called_with("S: Logging event was not provided with message!")
            end)
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
