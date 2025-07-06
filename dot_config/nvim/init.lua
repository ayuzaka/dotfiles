vim.loader.enable()

require("config.plugins")
require("config.options")
require("config.keymaps")
require("config.command")
for _, file in ipairs(vim.fn.glob(vim.fn.stdpath('config') .. '/lua/config/commands/*.lua', true, true)) do
  require('config.commands.' .. vim.fn.fnamemodify(file, ':t:r'))
end
require("config.abbrev")
