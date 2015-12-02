--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

AdRegisterResponse = Class()

function AdRegisterResponse.new(self)
    local success
    local tokens
    local _error

    function self.init(_success, _tokens, _err)
        success = _success
        tokens = _tokens
        _error = _err
    end

    function self.isSuccess()
        return success
    end

    function self.getTokens()
        return tokens
    end

    function self.getError()
        return _error
    end
end
