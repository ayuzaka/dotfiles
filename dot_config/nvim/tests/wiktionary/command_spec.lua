describe(":Wiktionary", function()
  local calls

  before_each(function()
    calls = { normal = 0, visual = 0 }
    package.loaded["wiktionary"] = {
      lookup = function()
        calls.normal = calls.normal + 1
      end,
      lookup_visual = function()
        calls.visual = calls.visual + 1
      end,
    }
    pcall(vim.api.nvim_del_user_command, "Wiktionary")
    dofile(vim.fn.getcwd() .. "/dot_config/nvim/lua/config/commands/wiktionary.lua")
  end)

  after_each(function()
    pcall(vim.api.nvim_del_user_command, "Wiktionary")
    package.loaded["wiktionary"] = nil
  end)

  it("routes a command without a range to lookup", function()
    vim.cmd("Wiktionary")

    assert.are.same({ normal = 1, visual = 0 }, calls)
  end)

  it("routes an explicit range to lookup_visual", function()
    vim.cmd("1,1Wiktionary")

    assert.are.same({ normal = 0, visual = 1 }, calls)
  end)

  it("does not define fixed normal or visual mappings", function()
    assert.are.same({}, vim.fn.maparg("<leader>d", "n", false, true))
    assert.are.same({}, vim.fn.maparg("<leader>d", "x", false, true))
  end)
end)
