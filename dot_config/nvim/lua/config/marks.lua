-- Native mark signs: display lowercase (a-z) and uppercase (A-Z) marks
-- in the sign column using extmarks. Replaces chentoast/marks.nvim.

local ns = vim.api.nvim_create_namespace("native_marks")

local function refresh_marks(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local marks = {}

  -- lowercase marks (a-z): buffer-local
  for i = 0, 25 do
    local letter = string.char(string.byte("a") + i)
    local mark = vim.api.nvim_buf_get_mark(bufnr, letter)
    if mark[1] ~= 0 then
      marks[#marks + 1] = { letter = letter, line = mark[1] }
    end
  end

  -- uppercase marks (A-Z): global, show only if in current buffer
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  for i = 0, 25 do
    local letter = string.char(string.byte("A") + i)
    local mark = vim.api.nvim_get_mark(letter, {})
    if mark[1] ~= 0 and mark[4] == bufname then
      marks[#marks + 1] = { letter = letter, line = mark[1] }
    end
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for _, m in ipairs(marks) do
    if m.line >= 1 and m.line <= line_count then
      vim.api.nvim_buf_set_extmark(bufnr, ns, m.line - 1, 0, {
        sign_text = m.letter,
        sign_hl_group = "Identifier",
        priority = 10,
      })
    end
  end
end

local group = vim.api.nvim_create_augroup("NativeMarkSigns", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "CursorHold" }, {
  group = group,
  callback = function(args)
    refresh_marks(args.buf)
  end,
})
