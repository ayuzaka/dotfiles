local wiktionary = require("wiktionary")

local function is_visual_range(options)
  local start_position = vim.fn.getpos("'<")
  local end_position = vim.fn.getpos("'>")

  return vim.fn.visualmode() ~= "" and options.line1 == start_position[2] and options.line2 == end_position[2]
end

vim.api.nvim_create_user_command("Wiktionary", function(options)
  if options.range > 0 then
    if is_visual_range(options) then
      wiktionary.lookup_visual()
    else
      wiktionary.lookup_visual(options.line1, options.line2)
    end
  else
    wiktionary.lookup()
  end
end, {
  desc = "Look up a Japanese term in Wiktionary",
  range = true,
})
