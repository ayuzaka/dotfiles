local find_scratch_md_buffer = function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local ok, is_scratch_md = pcall(vim.api.nvim_buf_get_var, buf, "is_scratch_md")
      if ok and is_scratch_md then
        return buf
      end
    end
  end

  return nil
end

vim.api.nvim_create_user_command("ScratchMD", function()
  local scratch_buf = find_scratch_md_buffer()
  if scratch_buf ~= nil then
    vim.api.nvim_set_current_buf(scratch_buf)
    return
  end

  vim.cmd("enew")
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
  vim.b.is_scratch_md = true
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = 0,
    callback = function()
      vim.bo.modified = false
      vim.notify("ScratchMD: 保存をスキップしました", vim.log.levels.INFO)
    end,
  })
  vim.keymap.set("n", "<leader>sx", "<cmd>bd!<cr>", { buf = 0, desc = "Discard ScratchMD" })
end, {})

vim.keymap.set("n", "<leader>sm", "<cmd>ScratchMD<cr>", { desc = "Open ScratchMD" })
