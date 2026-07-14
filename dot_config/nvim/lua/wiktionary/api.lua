local M = {}

local endpoint = "https://ja.wiktionary.org/w/api.php"

local function build_arguments(user_agent, parameters)
  local arguments = {
    "curl",
    "--fail",
    "--get",
    "--location",
    "--silent",
    "--show-error",
    "--header",
    "Accept: application/json",
    "--user-agent",
    user_agent,
  }

  for _, parameter in ipairs(parameters) do
    table.insert(arguments, "--data-urlencode")
    table.insert(arguments, parameter)
  end

  table.insert(arguments, endpoint)
  return arguments
end

function M.new(options)
  local executable = options.executable or vim.fn.executable
  local schedule = options.schedule or vim.schedule
  local system = options.system or vim.system
  local user_agent = options.user_agent

  local function request(parameters, transform, callback)
    if executable("curl") ~= 1 then
      schedule(function()
        callback(nil, { kind = "curl_missing" })
      end)
      return
    end

    local started = pcall(system, build_arguments(user_agent, parameters), { text = true }, function(completed)
      schedule(function()
        if completed.code ~= 0 then
          callback(nil, { kind = completed.code == 22 and "api" or "network" })
          return
        end

        local decoded, payload = pcall(vim.json.decode, completed.stdout or "")
        if not decoded or type(payload) ~= "table" then
          callback(nil, { kind = "json" })
          return
        end

        if type(payload.error) == "table" then
          local kind = payload.error.code == "missingtitle" and "not_found" or "api"
          callback(nil, { kind = kind })
          return
        end

        local result, transform_error = transform(payload)
        callback(result, transform_error)
      end)
    end)

    if not started then
      schedule(function()
        callback(nil, { kind = "network" })
      end)
    end
  end

  local function parse(title, callback)
    request({
      "action=parse",
      "page=" .. title,
      "prop=text|sections",
      "format=json",
      "formatversion=2",
      "redirects=1",
    }, function(payload)
      if type(payload.parse) ~= "table"
        or type(payload.parse.title) ~= "string"
        or type(payload.parse.text) ~= "string"
      then
        return nil, { kind = "api" }
      end

      return {
        html = payload.parse.text,
        sections = type(payload.parse.sections) == "table" and payload.parse.sections or {},
        title = payload.parse.title,
      }, nil
    end, callback)
  end

  local function search(term, limit, callback)
    request({
      "action=query",
      "list=search",
      "srsearch=" .. term,
      "srnamespace=0",
      "srlimit=" .. tostring(limit),
      "format=json",
      "formatversion=2",
    }, function(payload)
      if type(payload.query) ~= "table" or type(payload.query.search) ~= "table" then
        return nil, { kind = "api" }
      end

      local titles = {}
      for _, item in ipairs(payload.query.search) do
        if type(item.title) == "string" and item.title ~= "" then
          table.insert(titles, item.title)
        end
      end

      return titles, nil
    end, callback)
  end

  return {
    parse = parse,
    search = search,
  }
end

return M
