vim.g.copilot_filetypes = {
  dotenv = false
}

local copilot_group = vim.api.nvim_create_augroup("disableGitHubCopilot", { clear = true })

local disable_paths = {
  "$HOME/workspace/ayuzaka/learn/*",
  "Users/ayuzaka/Downloads/diary/*",
  "$HOME/Documents/Obsidian Vault/*",
}

--vim.api.nvim_create_autocmd({"LspAttach"}, {
--  pattern = disable_paths,
--  group = copilot_group,
--  callback = function (args)
--    if not args['data'] or not args.data['client_id'] then return end
--
--    local client = vim.lsp.get_client_by_id(args.data.client_id)
--    if client.name == 'copilot' then
--      vim.lsp.stop_client(client.id, true)
--    end
--  end
--})

for _, pattern in ipairs(disable_paths) do
  vim.api.nvim_create_autocmd("LspAttach", {
    group = copilot_group,
    pattern = pattern,
    callback = vim.schedule_wrap(function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client.name == "copilot" then
        vim.cmd("Copilot detach")
      end
    end),
  })
end
