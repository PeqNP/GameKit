--[[
  Provides `Composite` for `Class`es.

  When the `combine` method is called, it is guaranteed that the subject will be
  initialized (i.e. the subject's `init` method will be called).

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

    local info = debug.getinfo(2, "Sl")
    local name = string.split(info.source, "/") -- remove everything before path
    -- @fixme This doesn't work with Lua 5.1. I'm not sure if it's because of
    -- the escape character used or what.
    name = string.split(name[#name], "%.") -- remove '.lua[c|o]' extension
    name = name[1]

    function composite._getName()
        return name
    end

    function composite.getProtocol()
        return protocol
    end

    function composite.combine(self, ...)
        Signal.fail(string.format("Composite (%s) must have a function used to combine itself with a subject class.", name))
    end 

    return composite
end
