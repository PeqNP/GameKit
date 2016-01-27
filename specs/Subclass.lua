--
-- This class is used to test subclassing a class by passing in
-- a path to the subclass. This prevents users from having to
-- require, associate and then pass in the reference to the class.
--

local Subclass = Class()

function Subclass.new(self)
    function self.init()
    end

    function self.getVar()
        return "var"
    end
end

return Subclass
