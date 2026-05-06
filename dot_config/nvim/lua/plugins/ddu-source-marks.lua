local bookmark_comments = require("config.bookmark_comments")

vim.keymap.set("n", "<Leader>m", function()
  vim.fn["ddu#start"]({ name = "marks" })
end, { silent = true })

vim.fn["ddu#custom#action"]("kind", "marks", "comment", function(args)
  if #args.items ~= 1 then
    vim.notify("Select exactly one mark to edit its comment", vim.log.levels.INFO)
    return 0
  end

  local action = args.items[1].action
  local letter = action and action.mark or nil
  vim.schedule(function()
    bookmark_comments.edit(letter)
  end)

  return 0
end)

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "ddu-ff-marks",
  callback = function()
    vim.keymap.set(
      "n",
      "c",
      "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'comment' })<CR>",
      { buffer = 0, silent = true }
    )
  end,
})
