-- image.nvim requires terminal environment (fails in headless mode)
local ok, image = pcall(require, "image")
if not ok then
  return
end

image.setup({
  backend = "kitty",
  processor = "magick_cli",
  integrations = {
    markdown = {
      enabled = true,
      download_remote_images = false,
      only_render_image_at_cursor = true,
    },
    neorg = { enabled = false },
    html = {
      enabled = true,
      download_remote_images = false,
      only_render_image_at_cursor = true,
    },
    css = {
      enabled = true,
      download_remote_images = false,
      only_render_image_at_cursor = true,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  window_overlap_clear_enabled = true,
  window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
})

-- 編集可能なバッファでは画像を表示しない（プレビュー専用）
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.modifiable then
      image.clear()
    end
  end,
})
