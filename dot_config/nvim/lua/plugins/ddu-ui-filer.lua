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

local function is_image_file(path)
  local ext = path:match("%.([^%.]+)$")
  if ext then
    ext = ext:lower()
  end

  return ext and image_extensions[ext]
end

local function find_preview_window(filer_win, wins_before, path)
  -- Find newly opened window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not wins_before[win] then
      return win
    end
  end

  -- If no new window, find window with matching buffer name
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= filer_win then
      local buf = vim.api.nvim_win_get_buf(win)
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname:match(vim.pesc(path)) then
        return win
      end
    end
  end

  return nil
end

local function render_image(preview_win, path)
  local ok, api = pcall(require, "image")
  if not ok then
    return
  end

  api.clear()
  local preview_buf = vim.api.nvim_win_get_buf(preview_win)
  local img = api.from_file(path, {
    window = preview_win,
    buffer = preview_buf,
    x = 0,
    y = 0,
    width = vim.api.nvim_win_get_width(preview_win),
    height = vim.api.nvim_win_get_height(preview_win),
  })
  if img then
    img:render()
  end
end

local function clear_image()
  local ok, api = pcall(require, "image")
  if ok then
    api.clear()
  end
end

local function preview_image(path)
  -- Close existing preview first to avoid toggle behavior
  clear_image()
  vim.fn["ddu#ui#do_action"]("closePreviewWindow")

  local filer_win = vim.api.nvim_get_current_win()
  local wins_before = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    wins_before[win] = true
  end

  vim.fn["ddu#ui#do_action"]("preview")

  vim.defer_fn(function()
    local preview_win = find_preview_window(filer_win, wins_before, path)
    if preview_win then
      render_image(preview_win, path)
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
    local opts = { buffer = true, silent = true }
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

    vim.keymap.set("n", "p", function()
      local item = vim.fn["ddu#ui#get_item"]()
      if not item or item.isTree then
        clear_image()
        vim.fn["ddu#ui#do_action"]("preview")
        return
      end

      local path = item.action and item.action.path or item.word
      if is_image_file(path) then
        preview_image(path)
      else
        clear_image()
        vim.fn["ddu#ui#do_action"]("preview")
      end
    end, opts)

    vim.keymap.set("n", "P", function()
      clear_image()
      vim.fn["ddu#ui#do_action"]("closePreviewWindow")
    end, opts)

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
