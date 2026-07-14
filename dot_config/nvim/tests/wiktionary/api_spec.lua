local api = require("wiktionary.api")

local function immediate_schedule(callback)
  callback()
end

local function has_argument(arguments, expected)
  for _, argument in ipairs(arguments) do
    if argument == expected then
      return true
    end
  end
  return false
end

local function client_for(completed, captured)
  return api.new({
    executable = function()
      return 1
    end,
    schedule = immediate_schedule,
    system = function(arguments, options, on_exit)
      captured.arguments = arguments
      captured.options = options
      on_exit(completed)
      return {}
    end,
    user_agent = "nvim-wiktionary/test",
  })
end

describe("wiktionary.api", function()
  it("requests a parsed page asynchronously with curl data encoding", function()
    local captured = {}
    local client = client_for({
      code = 0,
      stderr = "",
      stdout = vim.json.encode({
        parse = {
          redirects = { { from = "がいねん", to = "概念" } },
          sections = { { line = "日本語" } },
          text = "<h2>日本語</h2>",
          title = "概念",
        },
        warnings = { parse = { warnings = "prop=sections is deprecated" } },
      }),
    }, captured)
    local page

    client.parse("がいねん", function(result, err)
      assert.is_nil(err)
      page = result
    end)

    assert.are.same({
      html = "<h2>日本語</h2>",
      sections = { { line = "日本語" } },
      title = "概念",
    }, page)
    assert.are.equal(true, has_argument(captured.arguments, "--get"))
    assert.are.equal(true, has_argument(captured.arguments, "--data-urlencode"))
    assert.are.equal(true, has_argument(captured.arguments, "page=がいねん"))
    assert.are.equal(true, has_argument(captured.arguments, "prop=text|sections"))
    assert.are.equal(true, has_argument(captured.arguments, "redirects=1"))
    assert.are.equal(true, has_argument(captured.arguments, "nvim-wiktionary/test"))
    assert.are.same({ text = true }, captured.options)
  end)

  it("requests search candidates with the configured limit", function()
    local captured = {}
    local client = client_for({
      code = 0,
      stderr = "",
      stdout = vim.json.encode({
        query = {
          search = {
            { title = "概念" },
            { title = "概念化" },
          },
        },
      }),
    }, captured)
    local candidates

    client.search("がいねん", 7, function(result, err)
      assert.is_nil(err)
      candidates = result
    end)

    assert.are.same({ "概念", "概念化" }, candidates)
    assert.are.equal(true, has_argument(captured.arguments, "list=search"))
    assert.are.equal(true, has_argument(captured.arguments, "srnamespace=0"))
    assert.are.equal(true, has_argument(captured.arguments, "srlimit=7"))
  end)

  it("classifies malformed search items as API failures", function()
    local kinds = {}

    for _, item in ipairs({ false, { title = 7 } }) do
      local client = client_for({
        code = 0,
        stderr = "",
        stdout = vim.json.encode({
          query = {
            search = { item },
          },
        }),
      }, {})

      client.search("概念", 7, function(_, err)
        table.insert(kinds, err and err.kind or "success")
      end)
    end

    assert.are.same({ "api", "api" }, kinds)
  end)

  it("classifies MediaWiki and transport failures without exposing raw payloads", function()
    local cases = {
      {
        completed = { code = 0, stdout = "not-json", stderr = "" },
        expected = "json",
      },
      {
        completed = {
          code = 0,
          stdout = vim.json.encode({ error = { code = "missingtitle", info = "raw" } }),
          stderr = "",
        },
        expected = "not_found",
      },
      {
        completed = {
          code = 0,
          stdout = vim.json.encode({ error = { code = "internal_api_error", info = "raw" } }),
          stderr = "",
        },
        expected = "api",
      },
      {
        completed = { code = 22, stdout = "", stderr = "HTTP raw" },
        expected = "api",
      },
      {
        completed = { code = 6, stdout = "", stderr = "DNS raw" },
        expected = "network",
      },
    }

    for _, case in ipairs(cases) do
      local client = client_for(case.completed, {})
      local received_error

      client.parse("概念", function(_, err)
        received_error = err
      end)

      assert.are.equal(case.expected, received_error.kind)
      assert.is_nil(received_error.raw)
    end
  end)

  it("distinguishes a missing curl executable", function()
    local system_called = false
    local client = api.new({
      executable = function()
        return 0
      end,
      schedule = immediate_schedule,
      system = function()
        system_called = true
      end,
      user_agent = "nvim-wiktionary/test",
    })
    local received_error

    client.parse("概念", function(_, err)
      received_error = err
    end)

    assert.are.equal("curl_missing", received_error.kind)
    assert.is_false(system_called)
  end)

  it("keeps a completed result when system throws after exit", function()
    local calls = {}
    local client = api.new({
      executable = function()
        return 1
      end,
      schedule = immediate_schedule,
      system = function(_, _, on_exit)
        on_exit({
          code = 0,
          stderr = "",
          stdout = vim.json.encode({
            parse = {
              sections = {},
              text = "<h2>日本語</h2>",
              title = "概念",
            },
          }),
        })
        error("failure after exit")
      end,
      user_agent = "nvim-wiktionary/test",
    })

    client.parse("概念", function(result, err)
      table.insert(calls, { err = err, result = result })
    end)

    assert.are.same({
      {
        result = {
          html = "<h2>日本語</h2>",
          sections = {},
          title = "概念",
        },
      },
    }, calls)
  end)

  it("classifies a process start exception as a network failure", function()
    local client = api.new({
      executable = function()
        return 1
      end,
      schedule = immediate_schedule,
      system = function()
        error("spawn failure")
      end,
      user_agent = "nvim-wiktionary/test",
    })
    local received_error

    client.parse("概念", function(_, err)
      received_error = err
    end)

    assert.are.equal("network", received_error.kind)
  end)
end)
