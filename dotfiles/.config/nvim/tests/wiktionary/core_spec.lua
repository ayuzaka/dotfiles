local core = require("wiktionary.core")

local default_config = {
  border = "rounded",
  cache = true,
  max_definitions = 5,
  max_height = 30,
  max_width = 80,
  search_limit = 10,
}

local definitions = {
  {
    definitions = { "物事の意味内容。" },
    part_of_speech = "名詞",
  },
}

local function new_ui(choice)
  local state = {
    notifications = {},
    selections = {},
    shown = {},
  }

  return {
    notify = function(message, level)
      table.insert(state.notifications, { level = level, message = message })
    end,
    select = function(candidates, query, callback)
      table.insert(state.selections, { candidates = candidates, query = query })
      callback(choice == false and nil or choice or candidates[1])
    end,
    show = function(result, config)
      table.insert(state.shown, { config = config, result = result })
    end,
  }, state
end

local function successful_parser()
  return {
    extract = function()
      return definitions, nil
    end,
  }
end

describe("wiktionary.core", function()
  it("normalizes the query and reuses a session cache entry", function()
    local parse_calls = 0
    local client = {
      parse = function(title, callback)
        parse_calls = parse_calls + 1
        callback({ html = "html", sections = {}, title = title }, nil)
      end,
      search = function()
        error("search must not run for an exact page")
      end,
    }
    local ui, state = new_ui()
    local engine = core.new({
      client = client,
      config = default_config,
      now = function()
        return 123
      end,
      parser = successful_parser(),
      ui = ui,
    })

    engine.lookup("  概念\n")
    engine.lookup("概念")

    assert.are.equal(1, parse_calls)
    assert.are.equal(2, #state.shown)
    assert.are.equal("概念", state.shown[1].result.query)
    assert.are.equal("概念", state.shown[1].result.page_title)
    assert.are.equal(123, state.shown[1].result.fetched_at)
    assert.are.same(definitions, state.shown[1].result.entries)
  end)

  it("suppresses a reentrant lookup until the first lookup finishes", function()
    local engine
    local parse_calls = 0
    local reentered = false
    local show_calls = 0
    local client = {
      parse = function(title, callback)
        parse_calls = parse_calls + 1
        callback({ html = "html", sections = {}, title = title }, nil)
      end,
      search = function()
        error("search must not run")
      end,
    }
    local ui = {
      notify = function()
        error("notify must not run")
      end,
      select = function()
        error("select must not run")
      end,
      show = function()
        show_calls = show_calls + 1
        if not reentered then
          reentered = true
          engine.lookup("概念")
        end
      end,
    }
    engine = core.new({ client = client, config = default_config, parser = successful_parser(), ui = ui })

    engine.lookup("概念")

    assert.are.equal(1, parse_calls)
    assert.are.equal(1, show_calls)

    engine.lookup("概念")

    assert.are.equal(1, parse_calls)
    assert.are.equal(2, show_calls)
  end)

  it("bypasses the cache when cache is disabled", function()
    local parse_calls = 0
    local config = vim.tbl_extend("force", default_config, { cache = false })
    local client = {
      parse = function(title, callback)
        parse_calls = parse_calls + 1
        callback({ html = "html", sections = {}, title = title }, nil)
      end,
      search = function()
        error("search must not run")
      end,
    }
    local ui = new_ui()
    local engine = core.new({ client = client, config = config, parser = successful_parser(), ui = ui })

    engine.lookup("概念")
    engine.lookup("概念")

    assert.are.equal(2, parse_calls)
  end)

  it("searches only after a missing exact page and caches the chosen page under the original query", function()
    local parsed_titles = {}
    local search_calls = 0
    local client = {
      parse = function(title, callback)
        table.insert(parsed_titles, title)
        if title == "がいねん" then
          callback(nil, { kind = "not_found" })
        else
          callback({ html = "html", sections = {}, title = "概念" }, nil)
        end
      end,
      search = function(term, limit, callback)
        search_calls = search_calls + 1
        assert.are.equal("がいねん", term)
        assert.are.equal(10, limit)
        callback({ "概念", "概念化" }, nil)
      end,
    }
    local ui, state = new_ui("概念")
    local engine = core.new({ client = client, config = default_config, parser = successful_parser(), ui = ui })

    engine.lookup("がいねん")
    engine.lookup("がいねん")

    assert.are.same({ "がいねん", "概念" }, parsed_titles)
    assert.are.equal(1, search_calls)
    assert.are.equal(1, #state.selections)
    assert.are.equal("がいねん", state.shown[1].result.query)
    assert.are.equal("概念", state.shown[1].result.page_title)
    assert.are.equal(2, #state.shown)
  end)

  it("does not start a second request while the same query is pending", function()
    local parse_calls = 0
    local pending_callback
    local client = {
      parse = function(_, callback)
        parse_calls = parse_calls + 1
        pending_callback = callback
      end,
      search = function()
        error("search must not run")
      end,
    }
    local ui, state = new_ui()
    local engine = core.new({ client = client, config = default_config, parser = successful_parser(), ui = ui })

    engine.lookup("概念")
    engine.lookup("概念")
    assert.are.equal(1, parse_calls)

    pending_callback({ html = "html", sections = {}, title = "概念" }, nil)
    assert.are.equal(1, #state.shown)
  end)

  it("notifies when search returns no candidates", function()
    local client = {
      parse = function(_, callback)
        callback(nil, { kind = "not_found" })
      end,
      search = function(_, _, callback)
        callback({}, nil)
      end,
    }
    local ui, state = new_ui()
    local engine = core.new({ client = client, config = default_config, parser = successful_parser(), ui = ui })

    engine.lookup("未登録語")

    assert.are.equal('Wiktionaryに「未登録語」のページが見つかりませんでした。', state.notifications[1].message)
    assert.are.equal(vim.log.levels.ERROR, state.notifications[1].level)
  end)

  it("maps API failures to stable user-facing messages", function()
    local cases = {
      { kind = "curl_missing", message = "curlが見つかりません。" },
      { kind = "network", message = "Wiktionaryへの接続に失敗しました。" },
      { kind = "api", message = "Wiktionary APIでエラーが発生しました。" },
      { kind = "json", message = "Wiktionary APIの応答を解析できませんでした。" },
    }

    for _, case in ipairs(cases) do
      local client = {
        parse = function(_, callback)
          callback(nil, { kind = case.kind })
        end,
        search = function()
          error("search must not run")
        end,
      }
      local ui, state = new_ui()
      local engine = core.new({ client = client, config = default_config, parser = successful_parser(), ui = ui })

      engine.lookup("概念")

      assert.are.equal(case.message, state.notifications[1].message)
      assert.is_nil(state.notifications[1].raw)
    end
  end)

  it("distinguishes Japanese-section, definition, and HTML extraction failures", function()
    local cases = {
      {
        kind = "missing_japanese",
        message = 'Wiktionaryの「概念」ページに日本語セクションがありません。',
      },
      {
        kind = "no_definitions",
        message = "語義を抽出できませんでした。\nhttps://ja.wiktionary.org/wiki/%e6%a6%82%e5%bf%b5",
      },
      {
        kind = "html_parse",
        message = "WiktionaryのHTMLを解析できませんでした。\nhttps://ja.wiktionary.org/wiki/%e6%a6%82%e5%bf%b5",
      },
    }

    for _, case in ipairs(cases) do
      local client = {
        parse = function(_, callback)
          callback({ html = "html", sections = {}, title = "概念" }, nil)
        end,
        search = function()
          error("search must not run")
        end,
      }
      local parser = {
        extract = function()
          return nil, { kind = case.kind }
        end,
      }
      local ui, state = new_ui()
      local engine = core.new({ client = client, config = default_config, parser = parser, ui = ui })

      engine.lookup("概念")

      assert.are.equal(case.message, state.notifications[1].message)
    end
  end)
end)
