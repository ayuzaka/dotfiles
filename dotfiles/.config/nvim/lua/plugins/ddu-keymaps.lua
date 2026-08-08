local M = {}

M.apply_common_normal = function(opts)
  vim.keymap.set("n", "<Space>", "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
  vim.keymap.set("n", "p", "<Cmd>call ddu#ui#do_action('preview')<CR>", opts)
  vim.keymap.set("n", "P", "<Cmd>call ddu#ui#do_action('closePreviewWindow')<CR>", opts)
  vim.keymap.set("n", "d", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'delete' })<CR>", opts)
end

return M
