local image_extensions = {
  png = true,
  jpg = true,
  jpeg = true,
  gif = true,
  webp = true,
  avif = true,
  bmp = true,
  ico = true,
  svg = true,
}

local function preview_image_after_layout()
  local item = vim.fn["ddu#ui#get_item"]()
  local path = item and item.action and item.action.path
  local extension = path and path:match("%.([^%.]+)$")

  if not extension or not image_extensions[extension:lower()] then
    vim.fn["ddu#ui#do_action"]("preview")
    return
  end

  vim.fn["ddu#ui#do_action"]("closePreviewWindow")

  local filer_win = vim.api.nvim_get_current_win()
  local wins_before = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    wins_before[win] = true
  end

  vim.fn["ddu#ui#do_action"]("preview")

  vim.defer_fn(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if not wins_before[win] then
        vim.fn["ddu#ui#filer#_preview_image"](
          path,
          win,
          vim.api.nvim_win_get_width(win),
          vim.api.nvim_win_get_height(win)
        )
        return
      end
    end

    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if win ~= filer_win then
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        if bufname:match(vim.pesc(path)) then
          vim.fn["ddu#ui#filer#_preview_image"](
            path,
            win,
            vim.api.nvim_win_get_width(win),
            vim.api.nvim_win_get_height(win)
          )
          return
        end
      end
    end
  end, 100)
end

vim.api.nvim_create_autocmd({ "TabEnter", "CursorHold", "FocusGained" }, {
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "ddu-filer" then
        vim.fn["ddu#ui#do_action"]("checkItems")
        return
      end
    end
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-filer",
  callback = function()
    local opts = { buf = 0, silent = true }
    local keymaps = require("plugins.ddu-keymaps")

    vim.keymap.set("n", "<CR>", function()
      local item = vim.fn["ddu#ui#get_item"]()
      if item and item.isTree then
        vim.fn["ddu#ui#do_action"]("itemAction", { name = "narrow" })
      else
        vim.fn["ddu#ui#do_action"]("itemAction", {
          name = "open",
          params = { command = "rightbelow vsplit" }
        })
      end
    end, opts)

    keymaps.apply_common_normal(opts)
    vim.keymap.set("n", "p", preview_image_after_layout, opts)

    vim.keymap.set("n", "..",
      "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'narrow', 'params': { 'path': '..' } })<CR>", opts)
    vim.keymap.set("n", "t", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'newFile' })<CR>", opts)
    vim.keymap.set("n", "mk", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'newDirectory' })<CR>", opts)
    vim.keymap.set("n", "r", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'rename' })<CR>", opts)
    vim.keymap.set("n", "q", "<Cmd>close<CR>", opts)

    vim.keymap.set("n", "l", function()
      local item = vim.fn["ddu#ui#get_item"]()
      if item and item.isTree then
        vim.fn["ddu#ui#do_action"]("expandItem", { mode = "toggle" })
      else
        vim.fn["ddu#ui#do_action"]("itemAction", {
          name = "open",
          params = { command = "rightbelow vsplit" }
        })
      end
    end, opts)
  end
})

vim.api.nvim_create_user_command("Filer", function()
  vim.fn["ddu#start"]({
    name = "filer",
    sourceOptions = {
      file = {
        path = vim.fn.expand("%:p:h")
      }
    }
  })
end, {})
