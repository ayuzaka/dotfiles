local function is_mo_running(mo_path)
  local result = vim.system({ mo_path, "--status", "--json" }, { text = true }):wait()
  if result.code ~= 0 then
    return false
  end

  local ok, servers = pcall(vim.json.decode, result.stdout)
  if not ok then
    return false
  end

  return vim.iter(servers):any(function(server)
    return server.url == "http://localhost:6275" and server.status == "running"
  end)
end

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

  local was_running = is_mo_running(mo_path)

  vim.cmd("update")
  vim.fn.jobstart({ mo_path, path }, {
    detach = true,
    stdin = "null",
    on_exit = function(_, exit_code)
      if was_running and exit_code == 0 then
        vim.schedule(function()
          vim.system({ "open", "-a", "Google Chrome" }, { detach = true })
        end)
      end
    end,
  })
end

vim.api.nvim_create_user_command("Mo", open_with_mo, {})
vim.keymap.set("n", "<leader>mo", "<cmd>Mo<cr>", { desc = "Open Markdown with mo" })
