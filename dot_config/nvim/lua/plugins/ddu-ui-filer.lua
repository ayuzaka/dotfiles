vim.api.nvim_create_autocmd({ "TabEnter", "CursorHold", "FocusGained" }, {
  callback = function()
    vim.fn["ddu#ui#do_action"]("checkItems")
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-filer",
  callback = function()
    local opts = { buffer = true, silent = true }

    vim.keymap.set("n", "<CR>", function()
      local item = vim.fn["ddu#ui#get_item"]()
      if item and item.isTree then
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "narrow" })
      else
        vim.fn["ddu#ui#do_action"]("itemAction", {
          name = "open",
          params = { command = "rightbelow vsplit" }
        })
      end
    end, opts)

    vim.keymap.set("n", "<Space>",
      "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
    vim.keymap.set("n", "p",
      "<Cmd>call ddu#ui#do_action('preview')<CR>", opts)
    vim.keymap.set("n", "q",
      "<Cmd>close<CR>", opts)
    vim.keymap.set("n", "..",
      "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'narrow', 'params': { 'path': '..' } })<CR>", opts)
    vim.keymap.set("n", "t",
      "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'newFile' })<CR>", opts)
    vim.keymap.set("n", "mk",
      "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'newDirectory' })<CR>", opts)
    vim.keymap.set("n", "r",
      "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'rename' })<CR>", opts)
    vim.keymap.set("n", "d",
      "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'delete' })<CR>", opts)

    vim.keymap.set("n", "l", function()
      local item = vim.fn["ddu#ui#get_item"]()
      if item and item.isTree then
        vim.fn["ddu#ui#do_action"]("expandItem", { mode = "toggle" })
      else
        vim.fn["ddu#ui#do_action"]("itemAction", {
          name = "open",
          params = { command = "rightbelow vsplit" }
        })
      end
    end, opts)
  end
})

vim.api.nvim_create_user_command("Filer", function()
  vim.fn["ddu#start"]({
    name = "filer",
    sourceOptions = {
      file = {
        path = vim.fn.expand("%:p:h")
      }
    }
  })
end, {})
