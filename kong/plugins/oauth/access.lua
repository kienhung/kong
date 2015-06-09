local stringy = require "stringy"
local utils = require "kong.tools.utils"
local cache = require "kong.tools.database_cache"
local responses = require "kong.tools.responses"

local _M = {}


local GET = "GET"
local POST = "POST"
local AUTHORIZE_URL = "/oauth2/authorize"

local function generate_authorize_html(conf, client, scopes)


  local application_owner = "thefosk"

  return [[
<html>
<head>
<title>Authorize ]]..client.name..[[</title>
</head>
<style>
  @import url(http://fonts.googleapis.com/css?family=Open+Sans);
  @media(max-width: 980px) {
    html {
      .graphic-text {
          font-size: 15px;
      }
    }
  }
  body {
    font-family: 'Open Sans', 'Helvetica Neue', 'Helvetica', 'Arial', 'Sans-Serif';
    font-size: 14px;
  }
</style>
<body>
<h1>Authorize Application</h1>
<p>Test by <b>]]..application_owner..[[</b> would like permissions to access your account</p>
<hr>
<h3>Review permissions</h3>

<form action="]]..AUTHORIZE_URL..[[" method="POST">
  <ul>
    <li>user:email</li>
  </ul>
  <input type="submit" value="Authorize application">
</form>
</body>
</html>
  ]]
end

local function generate_token(state)
  local token = dao.oauth2_tokens:insert()
  return {
    access_token = token.access_token
    token_type = "bearer",
    expires_in = token.expires_in,
    refresh_token = token.refresh_token,
    state = state -- If state is nil, this value won't be added
  }
end

local function get_redirect_uri(client_id)
  local client = cache.get_or_set(cache.oauth2_credential_key(client_id), function()
    local credentials, err = dao.oauth2_credentials:find_by_keys { client_id = client_id }
    local result
    if err then
      return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    elseif #credentials > 0 then
      result = credentials[1]
    end
    return result
  end)

  return client and client.redirect_uri or nil, client
end

local function authorize(conf, show_html)
  local response_params = {}

  local querystring = request.get_uri_args()
  local response_type = querystring["response_type"]
  local state = querystring["state"]

  if response_type == "code" or response_type == "token" then -- Authorization Code Grant (http://tools.ietf.org/html/rfc6749#section-4.1.1)
    local scope = querystring["scope"]

    if utils.table_contains(conf.scopes, scope) then
      local redirect_uri, client = get_redirect_uri(querystring["client_id"])

      if redirect_uri then
        if response_type == "code" then
          if show_html then
            responses.send_HTTP_OK(generate_authorize_html(conf, client, scope), true)
          else
            local authorization_code = dao.oauth2_authorization_codes:insert()
            response_params = {
              code = authorization_code.id
            }
          end
        elseif response_type == "token" then
          response_params = generate_token(state)
        end
      else
        response_params = {["error"] = "invalid_request", "Invalid client_id"}
      end
    else
      response_params = {["error"] = "invalid_scope", error_description = "Invalid scope"}
    end
  else
    response_params = {["error"] = "unsupported_response_type", error_description = "Invalid response_type"}
  end

  response_params.state = state
  ngx.redirect(redirect_uri.."?"..ngx.encode_args(response_params))
end

local function retrieve_token()
  ngx.req.read_body()
  local args = ngx.req.get_post_args()
  
  local grant_type = args["grant_type"]
  if grant_type == "authorization_code" then
    local code = args["code"]

    local redirect_uri = get_redirect_uri(querystring["client_id"])
    if redirect_uri then
      local authorization_code = dao.oauth2_authorization_codes:find_one(code)

      if authorization_code then
        responses.send_HTTP_OK(generate_token())
      end

    end

  end
end

function _M.execute(conf)
  local method = ngx.get_method()
  if (method == GET or method == POST) and stringy.endswith(ngx.var.request_uri, AUTHORIZE_URL) then
    authorize(conf, method == POST)
  elseif method == POST and stringy.endswith(ngx.var.request_uri, "/oauth2/token") then
    retrieve_token()
  end

end

return _M