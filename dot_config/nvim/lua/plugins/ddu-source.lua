vim.fn["ddu#custom#patch_local"]("fd", {
  sources = {
    {
      name = "file_external",
      params = {}
    }
  },
  sourceParams = {
    file_external = {
      cmd = { "fd", ".", "-H", "-t", "f", "--exclude", "*.{png,jpg,jpeg,webp,avif,gif}" }
    }
  }
})

vim.keymap.set("n", "<C-p>", function()
  vim.fn["ddu#start"]({ name = "fd" })
end, { silent = true })
