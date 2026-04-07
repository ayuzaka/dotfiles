local function send_to_app(target_app)
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

vim.api.nvim_create_user_command("SendTo", function(opts)
  send_to_app(opts.args)
end, { nargs = 1, desc = "Send buffer to specified app" })

vim.keymap.set("n", "<leader>s4", "<cmd>SendTo Google Chrome Canary<cr>", { desc = "Send buffer to Chrome Canary" })
vim.keymap.set("n", "<leader>s3", "<cmd>SendTo Slack<cr>", { desc = "Send buffer to Slack" })
