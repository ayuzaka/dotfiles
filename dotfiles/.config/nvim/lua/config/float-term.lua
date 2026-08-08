local term_buf = nil
local term_win = nil

local open_float_win = require("config.float-window")

local function open_float_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(term_buf, function()
      vim.fn.jobstart({ "zsh" }, {
        term = true, cwd = vim.fn.getcwd(),
        on_exit = function()
          if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            vim.api.nvim_buf_delete(term_buf, { force = true })
          end
          term_buf, term_win = nil, nil
        end,
      })
    end)
  end
  term_win = open_float_win(term_buf)
  vim.cmd("startinsert")
end

vim.keymap.set({ "n", "t" }, "<C-e>", function()
  if vim.fn.mode() == "t" then vim.cmd("stopinsert") end
  open_float_terminal()
end, { silent = true, nowait = true, desc = "Toggle floating terminal" })

vim.api.nvim_create_user_command("FloatTerm", open_float_terminal, {
  desc = "Toggle floating terminal",
})
