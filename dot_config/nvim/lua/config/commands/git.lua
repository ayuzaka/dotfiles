local function run_open_pr_by_hash()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No commit hash found under cursor.", vim.log.levels.INFO)
    return
  end

  local hash = word
  vim.fn.system("git rev-parse " .. hash .. " | xargs gh openpr")
end

vim.api.nvim_create_user_command("PRView", run_open_pr_by_hash, {})

local function gh_browse_current()
  local dir_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
  local remote_exists = vim.fn.system("git ls-remote --heads origin " .. branch)
  if remote_exists ~= "" then
    vim.fn.system("gh browse " .. dir_path .. " --branch " .. branch)
  else
    vim.notify("Branch '" .. branch .. "' is not pushed. Opening default branch.", vim.log.levels.WARN)
    vim.fn.system("gh browse " .. dir_path)
  end
end

vim.api.nvim_create_user_command("GhBrowse", gh_browse_current, {})
