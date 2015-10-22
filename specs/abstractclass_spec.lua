require "lang.Signal"

describe("AbstractClass", function()
    local subject
    local FakeAbstract
    local Subclass
    local FakeProtocol
    local protocol

    before_each(function()
        protocol = Protocol(
            Method("foo", true)
          , Method("bar", true)
        )
        FakeAbstract = Class()
        FakeAbstract.abstract(protocol)
        function FakeAbstract.new(self)
            function self.baz()
                return "baz"
            end
        end

        FakeProtocol = Protocol(
            Method("var", true)
          , Method("tmp", true)
        )

        Subclass = Class(FakeAbstract)
        Subclass.implements(FakeProtocol)
        function Subclass.new(self)
            function self.foo()
                return "foo"
            end
            function self.bar()
                return "bar"
            end
            function self.var()
                return "var"
            end
            function self.tmp()
                return "tmp"
            end
        end

        subject = Subclass()
    end)

    it("should have a baz method", function()
        assert.truthy(subject.baz)
    end)

    it("should conform to the abstract class's protocol", function()
        assert.truthy(subject.conformsTo(protocol))
    end)

    it("should conform to the FakeProtocol", function()
        assert.truthy(subject.conformsTo(FakeProtocol))
    end)

    it("should be a type of FakeAbstract", function()
        assert.truthy(subject.kindOf(FakeAbstract))
    end)
end)
