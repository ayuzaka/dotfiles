local M = {}

M.get_visual_text = function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line_index = start_pos[2] - 1
  local start_col_index = start_pos[3] - 1
  local end_line_index = end_pos[2] - 1
  local end_col_index = end_pos[3] - 1
  local lines = vim.api.nvim_buf_get_lines(0, start_line_index, end_line_index + 1, false)
  if #lines == 0 then
    return ""
  end
  lines[#lines] = string.sub(lines[#lines], 1, end_col_index + 1)
  lines[1] = string.sub(lines[1], start_col_index + 1)
  return table.concat(lines, "\n")
end

return M
