local mo_url = "http://localhost:6275"

local function open_with_mo()
  local mo_path = vim.fn.exepath("mo")
  if mo_path == "" then
    vim.notify("mo not found", vim.log.levels.ERROR)
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Mo requires a named buffer", vim.log.levels.ERROR)
    return
  end

  vim.cmd("update")
  -- mo 自身の opener は使わず、nvim 側の vim.ui.open（terminal-browser）に寄せる
  vim.fn.jobstart({ mo_path, "--no-open", path }, {
    detach = true,
    stdin = "null",
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.schedule(function()
          vim.ui.open(mo_url)
        end)
      end
    end,
  })
end

vim.api.nvim_create_user_command("Mo", open_with_mo, {})
vim.keymap.set("n", "<leader>mo", "<cmd>Mo<cr>", { desc = "Open Markdown with mo" })
