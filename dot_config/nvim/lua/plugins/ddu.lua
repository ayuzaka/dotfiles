vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff",
  callback = function()
    local opts = { buf = 0, silent = true }
    local keymaps = require("plugins.ddu-keymaps")
    keymaps.apply_common_normal(opts)

    vim.keymap.set("n", "<CR>", "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
    vim.keymap.set("n", "a", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'add' })<CR>", opts)
    vim.keymap.set("n", "r", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'reset' })<CR>", opts)
    vim.keymap.set("n", "gd", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'diff' })<CR>", opts)
    vim.keymap.set("n", "i", "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
    vim.keymap.set("n", "q", "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)
  end
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "ddu-ff-git_blame", "ddu-ff-git_log" },
  callback = function()
    local opts = { buf = 0, silent = true }
    vim.keymap.set("n", "y", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'yank' })<CR>", opts)
  end
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "ddu-ff-git_log",
  callback = function()
    local opts = { buf = 0, silent = true }
    vim.keymap.set("n", "<CR>", function()
      local item = vim.fn["ddu#ui#get_item"]()
      if not item or vim.tbl_isempty(item) then return end

      local hash = item.action and item.action.hash
      if not hash then
        hash = item.word and item.word:match("^(%x+)")
      end
      if not hash then return end

      vim.fn["ddu#ui#do_action"]("quit")
      vim.schedule(function()
        vim.cmd("DiffviewOpen " .. hash .. "^.." .. hash)
      end)
    end, opts)
  end
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "ddu-ff-gh_pr_diff",
  callback = function()
    local opts = { buf = 0, silent = true }
    vim.keymap.set("n", "v", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'markAsViewed' })<CR>", opts)
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff-filter",
  callback = function()
    local opts = { buf = 0, silent = true }
    vim.keymap.set("i", "<CR>",
      "<Esc><Cmd>close<CR>", opts)
    vim.keymap.set("n", "<CR>",
      "<Cmd>close<CR>", opts)
    vim.keymap.set("n", "q",
      "<Cmd>close<CR>", opts)
  end
})

local vimx = require("artemis")
vimx.fn.ddu.custom.load_config(vimx.fn.expand("$XDG_CONFIG_HOME/nvim/ts/ddu.ts"))
