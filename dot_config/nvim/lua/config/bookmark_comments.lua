local M = {}

local state_path = vim.fn.stdpath("state") .. "/bookmark_comments.json"

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.ERROR)
end

local function read_comments()
  if vim.fn.filereadable(state_path) == 0 then
    return {}
  end

  local lines = vim.fn.readfile(state_path)
  if #lines == 0 then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(decoded) ~= "table" then
    notify("Failed to read bookmark comments: " .. state_path)
    return {}
  end

  local comments = {}
  for letter, comment in pairs(decoded) do
    if type(letter) == "string" and letter:match("^[A-Z]$") and type(comment) == "string" then
      comments[letter] = comment
    end
  end

  return comments
end

local function write_comments(comments)
  vim.fn.mkdir(vim.fn.fnamemodify(state_path, ":h"), "p")

  local ok, encoded = pcall(vim.json.encode, comments)
  if not ok then
    notify("Failed to encode bookmark comments", vim.log.levels.ERROR)
    return false
  end

  local write_ok, err = pcall(vim.fn.writefile, vim.split(encoded, "\n"), state_path)
  if not write_ok then
    notify("Failed to save bookmark comments: " .. err, vim.log.levels.ERROR)
    return false
  end

  return true
end

local function list_uppercase_marks()
  local marks = {}

  for i = 0, 25 do
    local letter = string.char(string.byte("A") + i)
    local mark = vim.api.nvim_get_mark(letter, {})
    local has_buffer = mark[3] ~= 0
    local has_file = type(mark[4]) == "string" and mark[4] ~= ""
    if mark[1] ~= 0 and (has_buffer or has_file) then
      marks[#marks + 1] = {
        bufnr = mark[3],
        letter = letter,
        line = mark[1],
      }
    end
  end

  return marks
end

function M.clear(letter)
  local comments = read_comments()
  if comments[letter] == nil then
    return true
  end

  comments[letter] = nil
  return write_comments(comments)
end

function M.set(letter, comment)
  local comments = read_comments()

  if comment == "" then
    comments[letter] = nil
  else
    comments[letter] = comment
  end

  return write_comments(comments)
end

function M.get(letter)
  return read_comments()[letter]
end

function M.reconcile()
  local comments = read_comments()
  local active = {}

  for _, mark in ipairs(list_uppercase_marks()) do
    active[mark.letter] = true
  end

  local changed = false
  for letter in pairs(comments) do
    if not active[letter] then
      comments[letter] = nil
      changed = true
    end
  end

  if changed then
    write_comments(comments)
  end

  return comments
end

function M.edit(letter)
  if not letter or not letter:match("^[A-Z]$") then
    vim.notify("Bookmark comment supports uppercase marks only", vim.log.levels.WARN)
    return
  end

  local comments = M.reconcile()

  vim.ui.input({
    prompt = letter .. " comment: ",
    default = comments[letter] or "",
  }, function(input)
    if input == nil then
      return
    end

    local trimmed = vim.trim(input)
    if trimmed == "" then
      M.clear(letter)
      return
    end

    M.set(letter, trimmed)
  end)
end

local function show_comment()
  local comments = M.reconcile()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local items = {}

  local function build_items()
    comments = M.reconcile()

    local next_items = {}
    for _, mark in ipairs(list_uppercase_marks()) do
      if mark.bufnr == bufnr and mark.line == row and comments[mark.letter] then
        next_items[#next_items + 1] = {
          comment = comments[mark.letter],
          letter = mark.letter,
        }
      end
    end

    items = next_items
    return items
  end

  if #build_items() == 0 then
    vim.notify("No bookmark comments on this line", vim.log.levels.INFO)
    return
  end

  local function build_lines()
    local lines = {}
    local width = 0
    for _, item in ipairs(build_items()) do
      local line = string.format("%s: %s", item.letter, comments[item.letter])
      lines[#lines + 1] = line
      width = math.max(width, vim.fn.strdisplaywidth(line))
    end

    return lines, width
  end

  local initial_lines, initial_width = build_lines()
  local float_buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(float_buf, true, {
    border = "rounded",
    col = 1,
    height = #items,
    relative = "cursor",
    row = 1,
    style = "minimal",
    width = initial_width,
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function render()
    local lines, width = build_lines()
    if #lines == 0 then
      close()
      return
    end

    vim.bo[float_buf].modifiable = true
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
    vim.bo[float_buf].modifiable = false
    vim.api.nvim_win_set_config(win, {
      border = "rounded",
      col = 1,
      height = #lines,
      relative = "cursor",
      row = 1,
      style = "minimal",
      width = width,
    })
  end

  local function current_item()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    return items[line]
  end

  local function delete_comment()
    local item = current_item()
    if not item then
      return
    end

    M.clear(item.letter)
    render()
  end

  local function edit_comment()
    local item = current_item()
    if not item then
      return
    end

    close()
    vim.schedule(function()
      M.edit(item.letter)
    end)
  end

  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, initial_lines)
  vim.bo[float_buf].modifiable = false

  vim.keymap.set("n", "q", close, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "d", delete_comment, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "e", edit_comment, { buffer = float_buf, silent = true })
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = float_buf,
    once = true,
    callback = close,
  })
end

vim.keymap.set("n", "<leader>bk", show_comment, { desc = "Show bookmark comment", silent = true })

return M
