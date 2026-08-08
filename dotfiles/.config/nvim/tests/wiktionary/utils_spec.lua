local utils = require("config.utils")

describe("config.utils visual query", function()
  before_each(function()
    vim.cmd("enew!")
  end)

  after_each(function()
    vim.cmd("normal! \27")
  end)

  it("reads the active multibyte visual selection", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "日本語辞書" })
    vim.cmd("normal! gg0vll")

    assert.are.equal("日本語", utils.get_visual_query_text())
  end)

  it("normalizes the last multiline visual selection", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "  日本語", "辞書  " })
    vim.cmd("normal! ggVj")
    vim.cmd("normal! \27")
    vim.fn.setpos("'<", { 0, 1, 1, 0 })
    vim.fn.setpos("'>", { 0, 2, 1, 0 })

    assert.are.equal("日本語 辞書", utils.get_visual_query_text())
  end)
end)
