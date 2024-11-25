local function git_show_current_hash()
  local hash = vim.fn.expand("<cword>")
  vim.cmd("Git show ".. hash)
end

vim.api.nvim_create_user_command("Gb", "Git blame", {})
