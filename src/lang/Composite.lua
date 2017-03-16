--[[
  Provides `Composite` for `Class`es.

  When the `combine` method is called, it is guaranteed that the subject will be
  initialized (i.e. the subject's `init` method will be called).

  This also means that the subject can not call _any_ method associated to the
  `Composite` within its respective `init` method as the methods have not yet
  been applied.

  Methods in the subject class will always override the methods in the `Composite`.

  ## Providing Dependencies

  The composite may define a protocol which the subject conforms to. Similar
  to a delegate model, this ensures that the composite can ask the subject
  questions about its current state or resources required by the composite to
  do its work.

  This ensures:
  - The composite is decoupled (can be used by any other class with little effort)
  - The composite can be tested in isolation

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
