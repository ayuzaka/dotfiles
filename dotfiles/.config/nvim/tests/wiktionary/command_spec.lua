describe(":Wiktionary", function()
  local calls

  before_each(function()
    vim.cmd("enew!")
    calls = { normal = 0, visual = {} }
    package.loaded["wiktionary"] = {
      lookup = function()
        calls.normal = calls.normal + 1
      end,
      lookup_visual = function(line1, line2)
        table.insert(calls.visual, { line1, line2 })
      end,
    }
    pcall(vim.api.nvim_del_user_command, "Wiktionary")
    dofile(vim.fn.getcwd() .. "/dotfiles/.config/nvim/lua/config/commands/wiktionary.lua")
  end)

  after_each(function()
    pcall(vim.api.nvim_del_user_command, "Wiktionary")
    package.loaded["wiktionary"] = nil
  end)

  it("routes a command without a range to lookup", function()
    vim.cmd("Wiktionary")

    assert.are.same({ normal = 1, visual = {} }, calls)
  end)

  it("routes an explicit range to lookup_visual", function()
    vim.cmd("1,1Wiktionary")

    assert.are.same({ normal = 0, visual = { { 1, 1 } } }, calls)
  end)

  it("preserves the active visual selection", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "日本語辞書" })
    local keys = vim.api.nvim_replace_termcodes("gg0vll:Wiktionary<CR>", true, false, true)

    vim.api.nvim_feedkeys(keys, "xt", false)

    assert.are.same({ normal = 0, visual = { {} } }, calls)
  end)

  it("does not define fixed normal or visual mappings", function()
    assert.are.same({}, vim.fn.maparg("<leader>d", "n", false, true))
    assert.are.same({}, vim.fn.maparg("<leader>d", "x", false, true))
  end)
end)
