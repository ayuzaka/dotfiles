describe("wiktionary public facade", function()
  local captured

  local function load_wiktionary()
    package.loaded["wiktionary"] = nil
    package.loaded["wiktionary.api"] = {
      new = function(options)
        captured.api_options = options
        return { parse = function() end, search = function() end }
      end,
    }
    package.loaded["wiktionary.core"] = {
      new = function(dependencies)
        captured.config = vim.deepcopy(dependencies.config)
        return {
          lookup = function(query)
            table.insert(captured.queries, query)
          end,
        }
      end,
    }
    package.loaded["wiktionary.parser"] = { extract = function() end }
    package.loaded["wiktionary.ui"] = { notify = function() end }
    return require("wiktionary")
  end

  before_each(function()
    captured = { queries = {} }
    vim.cmd("enew!")
  end)

  after_each(function()
    vim.cmd("normal! \27")
    package.loaded["wiktionary"] = nil
    package.loaded["wiktionary.api"] = nil
    package.loaded["wiktionary.core"] = nil
    package.loaded["wiktionary.parser"] = nil
    package.loaded["wiktionary.ui"] = nil
  end)

  it("merges setup options and looks up kanji, hiragana, and katakana cwords", function()
    local wiktionary = load_wiktionary()
    wiktionary.setup({
      cache = false,
      max_definitions = 3,
      search_limit = 7,
      user_agent = "nvim-wiktionary/custom",
    })
    local line = "概念 ひらがな カタカナ"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { line })
    for _, term in ipairs({ "概念", "ひらがな", "カタカナ" }) do
      local byte_index = assert(line:find(term, 1, true))
      vim.api.nvim_win_set_cursor(0, { 1, byte_index - 1 })
      wiktionary.lookup()
    end

    assert.are.same({ "概念", "ひらがな", "カタカナ" }, captured.queries)
    assert.are.equal("nvim-wiktionary/custom", captured.api_options.user_agent)
    assert.are.equal(false, captured.config.cache)
    assert.are.equal(3, captured.config.max_definitions)
    assert.are.equal(7, captured.config.search_limit)
    assert.are.equal(80, captured.config.max_width)
    assert.are.equal(30, captured.config.max_height)
    assert.are.equal("rounded", captured.config.border)
  end)

  it("looks up the active visual selection", function()
    local wiktionary = load_wiktionary()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "日本語辞書" })
    vim.cmd("normal! gg0vll")

    wiktionary.lookup_visual()

    assert.are.same({ "日本語" }, captured.queries)
    assert.are.equal("nvim-wiktionary/0.1", captured.api_options.user_agent)
    assert.are.equal(true, captured.config.cache)
    assert.are.equal(10, captured.config.search_limit)
  end)
end)
