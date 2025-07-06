local function open_pr_by_hash(args)
  local hash = args.args
  vim.fn.system("git rev-parse " .. hash .. " | xargs gh openpr")
end

local function run_open_pr_by_hash()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No commit hash found under cursor.", vim.log.levels.INFO)
    return
  end

  open_pr_by_hash({ args = word })
end

local function get_current_latest_blame_hash()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local blame = vim.fn.system(string.format("git blame -L %d,%d %s", line, line, file))

  return vim.split(blame, "\n")[1]:match("^(%x+)")
end

local function run_open_pr_current_line()
  local hash = get_current_latest_blame_hash()
  open_pr_by_hash({ args = hash })
end

vim.api.nvim_create_user_command("OpenPRCurrentLine", run_open_pr_current_line, {})
vim.api.nvim_create_user_command("OpenPR", run_open_pr_by_hash, {})

local function git_browse_current()
  local dir_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  vim.fn.system("gh browse " .. dir_path)
end

vim.api.nvim_create_user_command("GitBrowse", git_browse_current, {})
