--[[
  Provides `Composite` for `Class`es.

  When the `combine` method is called, the subject is not yet fully initialized.
  Therefore, protocol methods can not be called immediately. A `Composite` can
  return a callback which gets executed _after_ the subject is initialized. This
  allows a composite to set state and variables immediately after initialization.

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
