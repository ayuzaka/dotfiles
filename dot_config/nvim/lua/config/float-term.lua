local term_buf = nil
local term_win = nil

local get_project_root_name = function()
  local cwd = vim.fn.getcwd()
  local workspace = vim.fn.expand("~/github")
  local name

  if vim.startswith(cwd, workspace .. "/") then
    -- ~/github 配下の場合は相対パスを使用
    name = cwd:sub(#workspace + 2)
  else
    name = vim.fn.fnamemodify(cwd, ":t")
  end

  local sanitized = name:gsub("%s+", "_"):gsub("[^%w%-%_%./]", "_")
  if sanitized == "" then
    return "project"
  end
  return sanitized
end

local function open_float_win(buf)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "single",
  })
  return win
end

local open_tmux_session = function()
  -- フローティングウィンドウが開いている場合は閉じるだけ
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
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

  -- バッファが生きていればそのまま再利用、なければ新規作成
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    term_win = open_float_win(term_buf)
    vim.cmd("startinsert")
  else
    term_buf = vim.api.nvim_create_buf(false, true)
    term_win = open_float_win(term_buf)
    vim.api.nvim_buf_call(term_buf, function()
      vim.fn.jobstart("tmux new-session -A -s " .. vim.fn.shellescape(session_name), {
        term = true,
        on_exit = function()
          if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            vim.api.nvim_buf_delete(term_buf, { force = true })
          end
          term_buf = nil
          term_win = nil
        end,
      })
    end)
    vim.cmd("startinsert")
  end
end

vim.keymap.set({ "n", "t" }, "<C-\\>", open_tmux_session, { silent = true, desc = "Toggle floating tmux session" })
