local term_buf = nil
local term_win = nil

local get_project_root_name = function()
  local cwd = vim.fn.getcwd()
  local workspace = vim.fn.expand("~/workspace/github.com")
  local name

  if vim.startswith(cwd, workspace .. "/") then
    -- workspace 配下の場合は相対パスを使用
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

-- tmuxはセッション名に "." が含まれると -t 指定を window/pane 区切りと
-- 誤解釈するため（例: "foo/.git-wt/bar" → pane "git-wt/bar" 扱いで見つからずエラー）、
-- 既存セッションの参照には session_name ではなく session_id を使う。
-- session_id は "$5" のように "$" を含むため、system()/jobstart() に渡す際は
-- shellescape してシェルによる変数展開を防ぐこと。
local function get_tmux_session_id(session_name)
  local output = vim.fn.system("tmux list-sessions -F '#{session_id}\t#{session_name}' 2>/dev/null")
  for id, name in output:gmatch("([^\t]+)\t([^\n]+)\n") do
    if name == session_name then
      return id
    end
  end
  return nil
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
    local session_id = get_tmux_session_id(session_name)
    if not session_id then
      -- セッションが無ければ作ってから id を取得する
      vim.fn.system("tmux new-session -d -s " .. vim.fn.shellescape(session_name))
      session_id = get_tmux_session_id(session_name)
    end
    vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(session_id))
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
      local session_id = get_tmux_session_id(session_name)
      local tmux_cmd = session_id and ("tmux attach-session -t " .. vim.fn.shellescape(session_id))
        or ("tmux new-session -s " .. vim.fn.shellescape(session_name))
      vim.fn.jobstart(tmux_cmd, {
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

vim.api.nvim_create_user_command("FloatTerm", open_tmux_session, {
  desc = "Toggle floating tmux session",
})
