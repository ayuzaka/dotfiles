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

vim.g.lsp_settings_filetype_javascript = { "typescript-language-server", "eslint-language-server" }
vim.g.lsp_settings_filetype_typescript = { "typescript-language-server", "eslint-language-server", "deno", "biome" }
vim.g.lsp_settings_filetype_typescriptreact = { "typescript-language-server", "eslint-language-server", "deno", "biome" }
vim.g.lsp_settings_filetype_html = { "html-languageserver", "tailwindcss-intellisense" }
vim.g.lsp_settings_filetype_css = { "vscode-css-language-server", "tailwindcss-intellisense", "biome" }
vim.g.lsp_settings_filetype_json = { "biome" }
vim.g.lsp_settings_filetype_jsonc = { "biome" }
vim.g.lsp_settings_filetype_svelte = { "svelte-language-server", "eslint-language-server" }
vim.g.lsp_settings_filetype_vue = { "volar-server", "vtsls", "eslint-language-server" }
vim.g.lsp_settings_filetype_python = { "pylsp-all", "pyright-langserver" }

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
  }
}

vim.api.nvim_create_autocmd("User", {
  pattern = "lsp_setup",
  callback = function()
    local function is_biome_json_present()
      local cwd = vim.loop.cwd()
      local biome_path = cwd .. "/biome.json"
      local stat = vim.loop.fs_stat(biome_path)
      return stat and stat.type == "file"
    end

    if not is_biome_json_present() then
      vim.g.lsp_settings = {
        ["biome"] = {
          disabled = 1,
          allowlist = { "typescript", "typescriptreact", "css", "json", "jsonc" }
        }
      }
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
