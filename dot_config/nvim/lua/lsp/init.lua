vim.diagnostic.config({
  virtual_text = true
})

local augroup = vim.api.nvim_create_augroup("lsp/init.lua", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = args.buf })
    vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = args.buf })

    vim.keymap.set("n", "[g", function()
      vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.WARN }, wrap = true })
    end, { buffer = args.buf, desc = "go to previous diagnostic" })

    vim.keymap.set("n", "]g", function()
      vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.WARN }, wrap = true })
    end, { buffer = args.buf, desc = "go to next diagnostic" })

    vim.keymap.set("n", "<leader>rn", function()
      vim.lsp.buf.rename()
    end, { buffer = args.buf, desc = "vim.lsp.buf.rename()" })

    vim.keymap.set("n", "<space>fmt", function()
      vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
    end, { buffer = args.buf, desc = "Format buffer" })

    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({
        border = "rounded",
      })
    end, { buffer = args.buf, desc = "hover" })

    vim.keymap.set("n", "<leader>d", function()
      local _, winid = vim.diagnostic.open_float(nil, { focus = true, border = "rounded" })
      if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_set_current_win(winid)
      end
    end, { buffer = args.buf, desc = "hover diagnostic" })
  end,
})

local lua_ls_opts = require("lsp.lua_ls")
vim.lsp.config("lua_ls", lua_ls_opts)

local vtsls_opts = require("lsp.vts_ls")
vim.lsp.config("vtsls", vtsls_opts)

local oxlint_opts = require("lsp.oxlint")
vim.lsp.config("oxlint", oxlint_opts)

vim.lsp.enable({
  "lua_ls",
  "gopls",
  "vue_ls",
  "svelte",
  "rust_analyzer",
  "pylsp",
  "bashls",
  "html",
  "cssls",
  "stylelint_lsp",
  "tailwindcss",
  "eslint",
  "biome",
  "oxlint",
  "gh_actions_ls",
  "docker_language_server",
  "efm",
})

-- vts_ls or deno
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("LspStartNodeOrDeno", { clear = true }),
  callback = function(ctx)
    if not vim.tbl_contains(
          { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
          ctx.match
        ) then
      return
    end

    -- nuxt
    if vim.fn.findfile("nuxt.config.ts", ".;") ~= "" then
      vim.lsp.enable("vtsls")
      return
    end

    -- node
    if vim.fn.findfile("package.json", ".;") ~= "" then
      vim.lsp.enable("ts_ls")
      return
    end

    -- deno
    vim.lsp.enable("denols")
  end,
})
