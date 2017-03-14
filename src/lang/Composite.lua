--[[
  Provides composition of classes.

  @copyright (c) 2017 Upstart Illustration LLC. All rights reserved.
  ]]

function Composite()
    return {}
end

--[[
  Add composite functionality of one class on to another.

  @param The class to add on to the `instance`.
  @param The instance of a class to add functionality to.
  ]]
function Compose(composite, instance, ...)
    local params = {...}
    composite.compose(instance, unpack(params))
end
