-- Quick Note: Raycast から起動した Ghostty + nvim で、
-- 同じアプリに複数回ペーストできるようにするためのコマンド。
-- ターゲットアプリは quick-note.sh が起動時にファイルに保存する。
-- :Send または <leader>se でバッファ内容をペーストし、バッファをクリアする。

local tmp_dir = (vim.env.TMPDIR or "/tmp"):gsub("/$", "")
local target_app_file = tmp_dir .. "/quick-note-target-app"

local function send_to_app()
  -- ターゲットアプリをファイルから読み取り
  local f = io.open(target_app_file, "r")
  if not f then
    vim.notify("Target app not set", vim.log.levels.ERROR)
    return
  end
  local target_app = f:read("*l")
  f:close()

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

vim.api.nvim_create_user_command("Send", send_to_app, {})
vim.keymap.set("n", "<leader>se", send_to_app, { desc = "Send buffer to target app" })
