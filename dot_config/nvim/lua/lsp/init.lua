vim.lsp.log._set_filename('/tmp/nvim/lsp.log')

vim.diagnostic.config({
  virtual_text = true
})

local augroup = vim.api.nvim_create_augroup("lsp/init.lua", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- https://github.com/vuejs/language-tools/wiki/Neovim
    -- Since v3.0.2, semantic tokens are handled on vue_ls side.
    -- Disable vtsls semantic tokens for Vue files to avoid conflict.
    if client.name == "vtsls" and client.server_capabilities.semanticTokensProvider then
      if vim.bo[args.buf].filetype == "vue" then
        client.server_capabilities.semanticTokensProvider.full = false
      end
    end

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

    if client.name == "ts_ls" or client.name == "vtsls" then
      local goto_source_definition = function()
        local offset_encoding = client.offset_encoding or "utf-16"
        local params = vim.lsp.util.make_position_params(0, offset_encoding)
        local uri = params.textDocument.uri
        local position = params.position
        local command = client.name == "vtsls" and "typescript.goToSourceDefinition" or
        "_typescript.goToSourceDefinition"

        vim.lsp.buf_request(args.buf, "workspace/executeCommand", {
          command = command,
          arguments = { uri, position },
        }, function(err, result)
          if err then
            vim.notify("Failed to go to Source Definition." .. err.message, vim.log.levels.ERROR)
            return
          end
          if not result then
            return
          end

          if #result == 1 then
            vim.lsp.util.show_document(result[1], offset_encoding, { focus = true })
            return
          end
          local items = vim.lsp.util.locations_to_items(result, offset_encoding)
          if not items or #items == 0 then
            return
          end

          vim.fn.setqflist({}, " ", { title = "GoToSourceDefinition", items = items })
          vim.cmd("copen")
          vim.cmd("wincmd p")
        end)
      end

      vim.keymap.set("n", "<C-d>s", goto_source_definition, { buffer = args.buf, desc = "Go to Source Definition" })
    end
  end,
})

local lua_ls_opts = require("lsp.lua_ls")
vim.lsp.config("lua_ls", lua_ls_opts)

local vtsls_opts = require("lsp.vts_ls")
vim.lsp.config("vtsls", vtsls_opts)

local oxlint_opts = require("lsp.oxlint")
vim.lsp.config("oxlint", oxlint_opts)

local oxfmt_opts = require("lsp.oxfmt")
vim.lsp.config("oxfmt", oxfmt_opts)

local tailwindcss_opts = require("lsp.tailwindcss")
vim.lsp.config("tailwindcss", tailwindcss_opts)

local actions_ls_opts = require("lsp.actionsls")
vim.lsp.config("actionsls", actions_ls_opts)

local zizmor_opts = require("lsp.zizmor")
vim.lsp.config("zizmor", zizmor_opts)

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
  "cssmodules_ls",
  "stylelint_lsp",
  "tailwindcss",
  "eslint",
  "biome",
  "oxlint",
  "oxfmt",
  "actionsls",
  "zizmor",
  "docker_language_server",
  "jsonls",
  "yamlls",
  "terraformls",
  "ember",
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
      vim.lsp.enable("tsgo")
      return
    end

    -- deno
    vim.lsp.enable("denols")
  end,
})
