vim.g.neoformat_try_node_exe = 1
vim.g.shfmt_opt = "-ci"

local oxfmt = {
  exe = "./node_modules/.bin/oxfmt",
  args = { "--stdin-filepath", "%:p" },
  stdin = 1,
  try_node_exe = 0,
}

vim.g.neoformat_javascript_oxfmt = oxfmt
vim.g.neoformat_typescript_oxfmt = oxfmt
vim.g.neoformat_javascriptreact_oxfmt = oxfmt
vim.g.neoformat_typescriptreact_oxfmt = oxfmt
