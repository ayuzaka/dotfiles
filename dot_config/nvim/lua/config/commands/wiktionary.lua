local wiktionary = require("wiktionary")

vim.api.nvim_create_user_command("Wiktionary", function(options)
  if options.range > 0 then
    wiktionary.lookup_visual()
  else
    wiktionary.lookup()
  end
end, {
  desc = "Look up a Japanese term in Wiktionary",
  range = true,
})
