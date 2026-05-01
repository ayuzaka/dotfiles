vim.lsp.config("sqls", {})
vim.lsp.enable("sqls")

local _original_ui_select = vim.ui.select
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(items, opts, on_choice)
  if opts and opts.prompt == "sqls.nvim" then
    local display_items = vim.tbl_map(function(item)
      return vim.split(item, " ")[3] or item
    end, items)
    _original_ui_select(display_items, opts, function(display_item, idx)
      if display_item == nil then
        on_choice(nil)
      else
        on_choice(items[idx])
      end
    end)
  else
    _original_ui_select(items, opts, on_choice)
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "SqlsConnectionChoice",
  callback = function(args)
    local choice = args.data and args.data.choice
    vim.g.sqls_current_connection = choice and vim.split(choice, " ")[3]
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function(args)
    vim.keymap.set("v", "<leader>sq", "<Plug>(sqls-execute-query)", {
      buf = args.buf,
      silent = true,
      desc = "Execute SQL query (visual)",
    })

    vim.keymap.set("n", "<leader>sc", "<Cmd>SqlsSwitchConnection<CR>", {
      buf = args.buf,
      silent = true,
      desc = "Switch SQL connection",
    })
  end,
})
