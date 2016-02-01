--
-- Provides convenience wrapper for Cocos2d-x XMLHttpRequest.
--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Logger"
require "HTTPResponseType"

local Promise = require("Promise")

local HTTP = Class()

function HTTP.new(self)
    --
    -- Query endpoint using GET as the given response type.
    --
    -- @param string - HTTP query string
    -- @param string - HTTPResponseType. Default: String
    -- @param fn - Callback made whenever status changes on network call.
    -- @return Promise - Resolves when status is between 200 and 299. Rejects otherwise.
    --
    function self.get(query, responseType, statusCallback)
        if not responseType then
            resopnseType = HTTPResponseType.String
        end

        Log.d("HTTP:get() - GET (%s) as (%s)", query, responseType)

        local promise = Promise()
        local request = cc.XMLHttpRequest:new()
        local function callback__complete()
            -- @todo statusCallback
            if request.status < 200 or request.status > 299 then
                promise.reject(request.status, request.statusText)
            else
                promise.resolve(request.status, request.response)
            end
        end
        request.responseType = HTTP.getMappedResponseType(responseType)
        request:registerScriptHandler(callback__complete)
        request:open("GET", query, true)
        request:send()
        return promise
    end
end

function HTTP.getMappedResponseType(_type)
    if _type == HTTPResponseType.Blob then
        return cc.XMLHTTPREQUEST_RESPONSE_BLOB
    elseif _type == HTTPResponseType.String then
        return cc.XMLHTTPREQUEST_RESPONSE_STRING
    end
    Log.w("Response type (%s) is not mapped to a known response type!", _type)
    return nil
end

return HTTP
