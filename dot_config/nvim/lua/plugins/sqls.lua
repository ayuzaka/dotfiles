local M = {}

local _pending_items = {}
local _pending_callback = nil

function M.handle_selection(idx)
  local callback = _pending_callback
  local items = _pending_items
  _pending_callback = nil
  _pending_items = {}

  if callback then
    callback(idx > 0 and items[idx] or nil)
  end
end

local private_ok, private_sqls = pcall(require, "private.sqls")
if private_ok and type(private_sqls.connection_configs) == "table" then
  require("config.sqls_dynamic_connections").setup({
    connection_configs = private_sqls.connection_configs,
  })
end

vim.lsp.config("sqls", {})
vim.lsp.enable("sqls")

local _original_ui_select = vim.ui.select
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(items, opts, on_choice)
  if opts and opts.prompt == "sqls.nvim" then
    local display_items = vim.tbl_map(function(item)
      return vim.split(item, " ")[3] or item
    end, items)

    _pending_items = items
    _pending_callback = on_choice
    vim.g.sqls_ddu_items = display_items

    vim.fn["ddu#start"]({ name = "sqls_connection" })

    vim.api.nvim_create_autocmd("BufDelete", {
      pattern = "ddu-ff-sqls_connection",
      once = true,
      callback = function()
        if _pending_callback then
          local cb = _pending_callback
          _pending_callback = nil
          _pending_items = {}
          cb(nil)
        end
      end,
    })
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

return M
