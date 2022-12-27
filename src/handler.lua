local cjson = require "cjson"
local kong_meta = require "kong.meta"
local uuid = require "uuid"

local kong = kong
local add_header = kong.service.request.add_header
local decode_base64 = ngx.decode_base64
local match = string.match
local rep = string.rep
local gsub = string.gsub

local function isempty(s)
    return s == nil or s == ''
end

local function base64_decode(input)
    local remainder = #input % 4

    if remainder > 0 then
        local padlen = 4 - remainder
        input = input .. rep("=", padlen)
    end

    input = input:gsub("-", "+"):gsub("_", "/")
    return decode_base64(input)
end

local function get_user_id(token)
    local header_64, claims_64, secret_64 = match(token, "(.*)%.(.*)%.(.*)")
    local claim = cjson.decode(base64_decode(claims_64))
    return claim["account_no"]
end

local function handle_request(conf)
    local raw_headers = kong.request.get_headers()
    local request_id
    local user_id

    if isempty(raw_headers["request_id"]) then
        request_id = uuid()
        add_header("request_id", request_id)
    else
        request_id = raw_headers["request_id"]
    end

    if not isempty(raw_headers["Authorization"]) then
        local token = gsub(raw_headers["Authorization"], "Bearer ", "")
        user_id = get_user_id(token)
        raw_headers["Authorization"] = nil
    end

    local response = cjson.encode({
        host = kong.request.get_host(),
        method = kong.request.get_method(),
        query = kong.request.get_path_with_query(),
        body = kong.request.get_raw_body(),
        headers = raw_headers,
        request_id = request_id,
        user_id = user_id
    })

    kong.log.err("Kong log request: ", response)
end

local function log_response()
    local raw_response_body = kong.response.get_raw_body()
    local raw_header = kong.response.get_headers()

end

local BodyLogHandler = {
    PRIORITY = 1000,
    VERSION = kong_meta.version,
}

function BodyLogHandler:access(conf)
    if conf.enable then
        handle_request(conf)
    end
end

function BodyLogHandler:body_filter(conf)
    if conf.enable then
        log_response()
    end
end

return BodyLogHandler