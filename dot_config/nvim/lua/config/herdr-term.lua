local term_buf = nil
local term_win = nil
local herdr_session = "agents"

local function git_output(cwd, args)
  local command = { "git", "-C", cwd }
  vim.list_extend(command, args)
  local output = vim.fn.systemlist(command)
  if vim.v.shell_error ~= 0 or not output[1] or output[1] == "" then
    return nil
  end
  return output[1]
end

local function get_herdr_context()
  local cwd = vim.fn.getcwd()
  local worktree_root = git_output(cwd, { "rev-parse", "--show-toplevel" })
  local common_dir = git_output(cwd, { "rev-parse", "--path-format=absolute", "--git-common-dir" })
  if not worktree_root or not common_dir then
    return nil
  end

  return {
    repo_root = vim.fn.fnamemodify(common_dir, ":h"),
    worktree_root = worktree_root,
  }
end

local function run_herdr(args)
  local command = { "herdr", "--session", herdr_session }
  vim.list_extend(command, args)
  local output = vim.fn.system(command)
  return vim.v.shell_error == 0, vim.trim(output)
end

local function get_workspace_id(output)
  local ok, response = pcall(vim.json.decode, output)
  if not ok then
    return nil
  end

  local result = response.result
  return result and result.workspace and result.workspace.workspace_id or nil
end

local function set_wezterm_user_var(name, value)
  if not vim.env.WEZTERM_PANE then
    return
  end

  io.stdout:write(string.format("\27]1337;SetUserVar=%s=%s\7", name, vim.base64.encode(value)))
  io.stdout:flush()
end

local function is_herdr_server_running()
  local command = { "herdr", "--session", herdr_session, "status", "server" }
  local output = vim.fn.system(command)
  return output:match("status: running") ~= nil
end

local function ensure_herdr_server()
  if is_herdr_server_running() then
    return true
  end

  local job_id = vim.fn.jobstart({ "herdr", "--session", herdr_session, "server" }, { detach = true })
  if job_id <= 0 then
    return false, "Herdr server を起動できません"
  end

  local started = vim.wait(2000, function()
    return is_herdr_server_running()
  end, 100)
  if not started then
    return false, "Herdr server の起動がタイムアウトしました"
  end

  return true
end

local function prepare_herdr_workspace(context)
  local ready, server_error = ensure_herdr_server()
  if not ready then
    return false, server_error
  end

  local parent_ready, workspace_output = run_herdr({
    "worktree",
    "open",
    "--cwd",
    context.repo_root,
    "--path",
    context.repo_root,
    "--focus",
    "--json",
  })
  if not parent_ready then
    return false, workspace_output
  end

  if context.worktree_root ~= context.repo_root then
    local worktree_ready, worktree_output = run_herdr({
      "worktree",
      "open",
      "--cwd",
      context.repo_root,
      "--path",
      context.worktree_root,
      "--focus",
      "--json",
    })
    if not worktree_ready then
      return false, worktree_output
    end
    workspace_output = worktree_output
  end

  local workspace_id = get_workspace_id(workspace_output)
  if not workspace_id then
    return false, "Herdr workspace ID を取得できません"
  end

  return true, nil, workspace_id
end

local open_float_win = require("config.float-window")

local open_herdr_session = function()
  -- フローティングウィンドウが開いている場合は閉じるだけ
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end

  local context = get_herdr_context()
  if not context then
    vim.notify("Git repository を検出できません", vim.log.levels.ERROR)
    return
  end

  if vim.fn.executable("herdr") ~= 1 then
    vim.notify("herdr が見つかりません", vim.log.levels.ERROR)
    return
  end

  local prepared, prepare_error, workspace_id = prepare_herdr_workspace(context)
  if not prepared then
    vim.notify(prepare_error ~= "" and prepare_error or "Herdr workspace を準備できません", vim.log.levels.ERROR)
    return
  end
  set_wezterm_user_var("HERDR_WORKSPACE_ID", workspace_id)

  -- バッファが生きていればそのまま再利用、なければ新規作成
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    term_win = open_float_win(term_buf)
    vim.cmd("startinsert")
  else
    term_buf = vim.api.nvim_create_buf(false, true)
    term_win = open_float_win(term_buf)
    vim.api.nvim_buf_call(term_buf, function()
      vim.fn.jobstart({ "herdr", "--session", herdr_session }, {
        term = true,
        cwd = context.worktree_root,
        on_exit = function()
          set_wezterm_user_var("HERDR_WORKSPACE_ID", "")
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

vim.keymap.set({ "n", "t" }, "<C-\\>", open_herdr_session, { silent = true, desc = "Toggle floating Herdr session" })

vim.api.nvim_create_user_command("HerdrTerm", open_herdr_session, {
  desc = "Toggle floating Herdr session",
})
