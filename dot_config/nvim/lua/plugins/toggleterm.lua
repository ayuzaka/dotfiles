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
local tmux_term = nil

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
  -- toggletermが開いている場合は閉じるだけ（tmuxの確認/起動はしない）
  if tmux_term ~= nil and tmux_term:is_open() then
    tmux_term:toggle()
    return
  end

  local session_name = get_project_root_name()
  if vim.env.TMUX and vim.env.TMUX ~= "" then
    -- tmux内ではセッションの有無を確認して切り替える
    vim.fn.system("tmux has-session -t " .. vim.fn.shellescape(session_name))
    if vim.v.shell_error == 0 then
      vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(session_name))
      return
    end
    -- セッションが無ければ作ってから切り替える
    vim.fn.system("tmux new-session -d -s " .. vim.fn.shellescape(session_name))
    vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(session_name))
    return
  end

  if tmux_term == nil then
    -- 端末インスタンスを使い回してtoggle時だけtmuxを起動する
    tmux_term = Terminal:new({
      cmd = vim.o.shell,
      hidden = true,
      direction = "float",
    })
  end

  -- toggletermを開くタイミングでtmuxセッションを起動/アタッチする
  tmux_term.cmd = "tmux new-session -A -s " .. vim.fn.shellescape(session_name)
  tmux_term:toggle()
end

vim.keymap.set({ "n", "t" }, "<C-\\>", open_tmux_session, { silent = true, desc = "ToggleTerm tmux session" })
