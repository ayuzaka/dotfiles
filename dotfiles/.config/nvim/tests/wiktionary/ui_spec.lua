local ui = require("wiktionary.ui")

local result = {
  entries = {
    {
      part_of_speech = "名詞",
      definitions = {
        "第一の意味",
        "第二の意味",
        "第三の意味",
        "第四の意味",
        "第五の意味",
        "第六の意味",
      },
    },
    {
      part_of_speech = "動詞",
      definitions = { "動作を表す" },
    },
  },
  fetched_at = 1,
  page_title = "概念",
  query = "がいねん",
}

describe("wiktionary.ui", function()
  local original_select

  before_each(function()
    original_select = vim.ui.select
    vim.cmd("enew!")
  end)

  after_each(function()
    vim.ui.select = original_select
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(winid).relative ~= "" then
        vim.api.nvim_win_close(winid, true)
      end
    end
  end)

  it("formats the query, resolved page, numbered definitions, and omitted count", function()
    assert.are.same({
      "がいねん",
      "ページ: 概念",
      "",
      "名詞",
      "1. 第一の意味",
      "2. 第二の意味",
      "3. 第三の意味",
      "4. 第四の意味",
      "5. 第五の意味",
      "…ほか1件",
      "",
      "動詞",
      "1. 動作を表す",
    }, ui.format_result(result, { max_definitions = 5 }))
  end)

  it("opens a focused bounded floating window with close mappings", function()
    local bufnr, winid = ui.show(result, {
      border = "rounded",
      max_definitions = 5,
      max_height = 4,
      max_width = 24,
    })

    assert.is_true(vim.api.nvim_buf_is_valid(bufnr))
    assert.is_true(vim.api.nvim_win_is_valid(winid))
    assert.are.equal(winid, vim.api.nvim_get_current_win())
    assert.is_true(vim.api.nvim_win_get_width(winid) <= 24)
    assert.is_true(vim.api.nvim_win_get_height(winid) <= 4)

    local lhs = {}
    for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(bufnr, "n")) do
      lhs[mapping.lhs] = true
    end
    assert.is_true(lhs.q)
    assert.is_true(lhs["<Esc>"])
  end)

  it("delegates candidates to vim.ui.select", function()
    local captured = {}
    vim.ui.select = function(items, options, on_choice)
      captured.items = items
      captured.options = options
      on_choice(items[2])
    end
    local selected

    ui.select({ "概念", "概念化" }, "がいねん", function(choice)
      selected = choice
    end)

    assert.are.same({ "概念", "概念化" }, captured.items)
    assert.are.equal("Wiktionaryの候補を選択: がいねん", captured.options.prompt)
    assert.are.equal("wiktionary", captured.options.kind)
    assert.are.equal("概念化", selected)
  end)
end)
