require("toggleterm").setup({
  size = 100,
  open_mapping = nil,
  shade_filetypes = {},
  shade_terminals = false,
  start_in_insert = true,
  insert_mappings = true,
  persist_size = true,
  direction = "float",
  close_on_exit = true,
})

local Terminal = require("toggleterm.terminal").Terminal

local get_project_root_name = function()
  local cwd = vim.fn.getcwd()
  local name = vim.fn.fnamemodify(cwd, ":t")
  local sanitized = name:gsub("%s+", "_"):gsub("[^%w%-%_%.]", "_")
  if sanitized == "" then
    return "project"
  end
  return sanitized
end

local open_tmux_session = function()
  local session_name = get_project_root_name()
  if vim.env.TMUX and vim.env.TMUX ~= "" then
    if vim.v.shell_error == 0 then
      vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(session_name))
      return
    end
    vim.fn.system("tmux new-session -d -s " .. vim.fn.shellescape(session_name))
    vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(session_name))
    return
  end

  local cmd = "tmux new-session -A -s " .. vim.fn.shellescape(session_name)
  local term = Terminal:new({
    cmd = cmd,
    hidden = true,
    direction = "float",
  })
  term:toggle()
end

vim.keymap.set("n", "<C-\\>", open_tmux_session, { silent = true, desc = "ToggleTerm tmux session" })
