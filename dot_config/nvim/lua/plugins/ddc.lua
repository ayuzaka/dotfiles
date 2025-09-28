vim.keymap.set("i", "<TAB>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.fn.col(".") <= 1 or string.match(vim.fn.getline("."):sub(vim.fn.col(".") - 2, vim.fn.col(".") - 2), "%s") then
    return "<TAB>"
  else
    return vim.fn["ddc#map#manual_complete"]()
  end
end, { expr = true, silent = true })

vim.keymap.set("i", "<S-TAB>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-h>"
end, { expr = true })

vim.fn["ddc#custom#load_config"](vim.fn.expand("$XDG_CONFIG_HOME/nvim/ts/ddc.ts"))

-- vim.fn["ddc#enable"]()
