-- Quick Note: Raycast から起動した Ghostty + nvim で、
-- 同じアプリに複数回ペーストできるようにするためのコマンド。
-- ターゲットアプリは quick-note.sh が起動時にファイルに保存する。
-- :Send または <leader>se でバッファ内容をペーストし、バッファをクリアする。
-- :SendTo <AppName> で任意のアプリを指定してペーストする。

local tmp_dir = (vim.env.TMPDIR or "/tmp"):gsub("/$", "")
local target_app_file = tmp_dir .. "/quick-note-target-app"

local function send_to_app(target_app)
  -- アプリ名が指定されていない場合はファイルから読み取り
  if not target_app or target_app == "" then
    local f = io.open(target_app_file, "r")
    if not f then
      vim.notify("Target app not set", vim.log.levels.ERROR)
      return
    end
    target_app = f:read("*l")
    f:close()
  end

  -- バッファ内容を取得
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  if content:match("^%s*$") then
    vim.notify("Buffer is empty", vim.log.levels.WARN)
    return
  end

  -- クリップボードにコピー
  vim.fn.setreg("+", content)

  -- ターゲットアプリをアクティブ化してペースト
  vim.fn.system({ "osascript", "-e", string.format('tell application "%s" to activate', target_app) })
  vim.fn.system({ "osascript", "-e", "delay 0.1", "-e", 'tell application "System Events" to keystroke "v" using command down' })

  -- バッファをクリア
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
  vim.notify("Sent to " .. target_app, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("Send", function() send_to_app() end, {})
vim.keymap.set("n", "<leader>se", function() send_to_app() end, { desc = "Send buffer to target app" })

vim.api.nvim_create_user_command("SendTo", function(opts)
  send_to_app(opts.args)
end, { nargs = 1, desc = "Send buffer to specified app" })
