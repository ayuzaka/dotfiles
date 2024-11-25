vim.fn["ddu#custom#alias"]("column", "icon_filename_for_ff", "icon_filename")

vim.fn["ddu#custom#patch_global"]({
  sourceOptions = {
    file = {
      columns = { "icon_filename" }
    },
    file_rec = {
      columns = { "icon_filename_for_ff" }
    }
  },
  columnParams = {
    icon_filename = {
      defaultIcon = {
        icon = "",
      }
    },
    icon_filename_for_ff = {
      defaultIcon = {
        icon = "",
      },
      padding = 0,
      pathDisplayOption = "relative"
    },
  }
})
