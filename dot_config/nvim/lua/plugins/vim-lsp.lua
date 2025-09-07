local function on_lsp_buffer_enabled()
  vim.bo.omnifunc = "lsp#complete"
  vim.wo.signcolumn = "yes"

  if vim.fn.exists("+tagfunc") == 1 then
    vim.bo.tagfunc = "lsp#tagfunc"
  end

--  vim.g.lsp_log_file = vim.fn.expand("~/.vim-lsp.log")

  local opts = { noremap = true, silent = true, buffer = true }
  vim.keymap.set("n", "<leader>rn", "<plug>(lsp-rename)", opts)
  vim.keymap.set("n", "[g", "<Plug>(lsp-previous-diagnostic)", opts)
  vim.keymap.set("n", "]g", "<Plug>(lsp-next-diagnostic)", opts)
  vim.keymap.set("n", "K", "<plug>(lsp-hover)", opts)
  vim.keymap.set("n", "<leader>K", ":LspHover --ui=preview<CR>", opts)

  -- スクロール設定
  vim.keymap.set('n', '<c-f>', function()
    -- ポップアップウィンドウが表示されているかチェック
    local win_list = vim.api.nvim_list_wins()
    local has_popup = false
    for _, win in ipairs(win_list) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        has_popup = true
        break
      end
    end

    if has_popup then
      return vim.fn['lsp#scroll'](4)
    else
      return '<c-f>'
    end
  end, { expr = true, buffer = true })

  vim.keymap.set('n', '<c-b>', function()
    -- ポップアップウィンドウが表示されているかチェック
    local win_list = vim.api.nvim_list_wins()
    local has_popup = false
    for _, win in ipairs(win_list) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        has_popup = true
        break
      end
    end

    if has_popup then
      return vim.fn['lsp#scroll'](-4)
    else
      return '<c-b>'
    end
  end, { expr = true, buffer = true })

end

-- オートコマンドグループの設定
vim.api.nvim_create_autocmd("User", {
  pattern = "lsp_buffer_enabled",
  callback = on_lsp_buffer_enabled
})

-- golangci-lint-langserverの設定
vim.api.nvim_create_autocmd("User", {
  pattern = "lsp_setup",
  callback = function()
    vim.fn["lsp#register_server"]({
      name = "golangci-lint-langserver",
      cmd = function() return { "golangci-lint-langserver" } end,
      initialization_options = {
        command = { "golangci-lint", "run", "--out-format", "json",
          "--issues-exit-code=1", "--config", "~/.config/golangci-lint/.golangci.yaml" }
      },
      allowlist = { "go" }
    })
  end
})

vim.keymap.set("n", "fmt", ":LspDocumentFormat<CR>", { silent = true })
vim.api.nvim_create_user_command("EfmFormat", "LspDocumentFormatSync --server=efm-langserver", {})

vim.g.lsp_signs_enabled = 1
vim.g.lsp_document_code_action_signs_enabled = 0
vim.g.lsp_diagnostics_echo_cursor = 1
vim.g.lsp_diagnostics_echo_delay = 50
vim.g.lsp_diagnostics_highlights_insert_mode_enabled = 0
vim.g.lsp_diagnostics_highlights_delay = 50
vim.g.lsp_diagnostics_signs_delay = 50
vim.g.lsp_diagnostics_signs_insert_mode_enabled = 0
vim.g.lsp_diagnostics_virtual_text_delay = 50
vim.g.lsp_diagnostics_virtual_text_enabled = 0
vim.g.lsp_completion_documentation_delay = 40
vim.g.lsp_document_highlight_delay = 100
vim.g.lsp_document_code_action_signs_delay = 100
vim.g.lsp_experimental_workspace_folders = 1

vim.g.lsp_settings_filetype_javascript = { "typescript-language-server", "eslint-language-server" }
vim.g.lsp_settings_filetype_typescript = { "typescript-language-server", "vtsls", "eslint-language-server", "deno", "biome" }
vim.g.lsp_settings_filetype_typescriptreact = { "typescript-language-server", "eslint-language-server", "deno", "biome" }
vim.g.lsp_settings_filetype_html = { "html-languageserver", "tailwindcss-intellisense" }
vim.g.lsp_settings_filetype_css = { "vscode-css-language-server", "tailwindcss-intellisense", "biome" }
vim.g.lsp_settings_filetype_json = { "biome" }
vim.g.lsp_settings_filetype_jsonc = { "biome" }
vim.g.lsp_settings_filetype_svelte = { "svelte-language-server", "eslint-language-server" }
vim.g.lsp_settings_filetype_vue = { "volar-server", "vtsls", "eslint-language-server" }
vim.g.lsp_settings_filetype_python = { "pylsp-all", "pyright-langserver" }
vim.g.lsp_settings_filetype_rust = { "rust-analyzer", "bacon-ls" }

vim.g.lsp_settings = {
  ["efm-langserver"] = {
    disabled = 0,
    allowlist = { "*" },
    blocklist = { "dotenv" }
  },
  ["pylsp-all"] = {
    workspace_config = {
      pylsp = {
        plugins = {
          jedi = {
            environment = ".venv/bin/python"
          }
        }
      }
    }
  },
  ["rust-analyzer"] = {
    initialization_options = {
      checkOnSave = false,
      diagnostics = false,
    }
  }
}

-- Ensure Biome only starts when a config exists
vim.g.lsp_settings = vim.tbl_deep_extend('force', vim.g.lsp_settings or {}, {
  ["biome"] = {
    root_markers = { "biome.json" },
  },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "lsp_setup",
  callback = function()
    local function file_exists(p)
      local st = vim.loop.fs_stat(p)
      return st and st.type == 'file'
    end

    local function has_file_upward(target)
      local buf = vim.api.nvim_get_current_buf()
      local file = vim.api.nvim_buf_get_name(buf)
      local dir = (file ~= '' and vim.fn.fnamemodify(file, ":p:h")) or vim.loop.cwd()
      while dir and dir ~= '' do
        if file_exists(dir .. '/' .. target) then return true end
        local parent = vim.fn.fnamemodify(dir, ':h')
        if parent == dir then break end
        dir = parent
      end
      return false
    end

    local has_biome = has_file_upward('biome.json')
    local has_nuxt = has_file_upward('nuxt.config.ts')

    local patch = {}
    if not has_biome then
      patch["biome"] = { disabled = 1 }
    end

    if has_nuxt then
      patch["typescript-language-server"] = { disabled = 1 }
    else
      patch["vtsls"] = { disabled = 1 }
    end

    if next(patch) ~= nil then
      vim.g.lsp_settings = vim.tbl_deep_extend('force', vim.g.lsp_settings or {}, patch)
    end
  end
})

local function eslint_fix()
  vim.cmd("!bunx eslint --fix " % "")
  vim.cmd("LspStopServer")
end

vim.api.nvim_create_user_command("ESLintFix", eslint_fix, {})

local function stylelint_fix()
  vim.cmd("!bunx stylelint --fix " % "")
  vim.cmd("LspStopServer")
end

vim.api.nvim_create_user_command("StylelintFix", stylelint_fix, {})
