-- Required dependency.
socket = require("socket")

Signal = {}
Signal.AssertOnFailure = true

function Signal.fail(msg)
    if Signal.AssertOnFailure then
        assert(false, msg)
    end
end

require "lang.Extensions"
require "lang.Protocol"
require "lang.Class"
require "lang.Composite"
require "lang.Switch"
require "lang.Set"
