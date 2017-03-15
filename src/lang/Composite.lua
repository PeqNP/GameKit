--[[
  Provides `Composite` for `Class`es.

  There are two possible ways to provide dependencies to a composite:

  1. Provide dependencies at subject's init time.
  2. The composite may define a protocol which the subject conforms to. Similar
     to a delegate model, this ensures that the composite can ask the subject
     questions about its current state or resources required by the composite to
     do its work.

  Both of these suggestions ensure:
  - The composite is decoupled, which allows for reusability and robustness.
  - The composite can be tested in isolation.

  @copyright (c) 2017 Upstart Illustration LLC. All rights reserved.
  ]]

function Composite(protocol)
    local composite = {}

    function composite.getProtocol()
        return protocol
    end

    function composite.combine(self, ...)
        assert(false, string.format("A Composite must have a function used to combine itself with a subject class."))
    end 

    return composite
end
