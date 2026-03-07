local M = {}

local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line_index = start_pos[2] - 1
  local end_line_index = end_pos[2] - 1
  local lines = vim.api.nvim_buf_get_lines(0, start_line_index, end_line_index + 1, false)

  return {
    end_pos = end_pos,
    lines = lines,
    start_pos = start_pos,
  }
end

local function get_visual_text_internal(options)
  local selection = get_visual_selection()
  local start_pos = selection.start_pos
  local end_pos = selection.end_pos
  local lines = selection.lines

  if #lines == 0 then
    return ""
  end

  if options.block_mode == "strict" then
    if vim.fn.visualmode() == "\22" then
      local start_col = math.min(start_pos[3], end_pos[3])
      local end_col = math.max(start_pos[3], end_pos[3])
      local block_lines = {}

      for _, line in ipairs(lines) do
        local selected = string.sub(line, start_col, end_col)
        table.insert(block_lines, selected)
      end

      return table.concat(block_lines, "\n")
    end

    local first_col = start_pos[3]
    local last_col = end_pos[3]
    if start_pos[2] == end_pos[2] then
      local col_start = math.min(first_col, last_col)
      local col_end = math.max(first_col, last_col)
      lines[1] = string.sub(lines[1], col_start, col_end)
      return table.concat(lines, "\n")
    end

    if start_pos[2] > end_pos[2] then
      first_col, last_col = last_col, first_col
    end

    lines[1] = string.sub(lines[1], first_col)
    lines[#lines] = string.sub(lines[#lines], 1, last_col)
    return table.concat(lines, "\n")
  end

  local start_col_index = start_pos[3] - 1
  local end_col_index = end_pos[3] - 1
  lines[#lines] = string.sub(lines[#lines], 1, end_col_index + 1)
  lines[1] = string.sub(lines[1], start_col_index + 1)
  return table.concat(lines, "\n")
end

local function normalize_query_text(text)
  local terms = {}
  for line in text:gmatch("[^\n]+") do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      table.insert(terms, trimmed)
    end
  end

  return table.concat(terms, " ")
end

M.get_visual_text = function()
  return get_visual_text_internal({ block_mode = "legacy" })
end

M.get_visual_query_text = function()
  local text = get_visual_text_internal({ block_mode = "strict" })
  return normalize_query_text(text)
end

M.get_quoted_text_under_cursor = function(line, col)
  local start_col = nil
  local quote_char = nil
  local index = 1
  local line_length = #line

  while index <= line_length do
    local char = line:sub(index, index)

    if not quote_char and (char == '"' or char == "'") then
      start_col = index
      quote_char = char
    elseif quote_char and char == quote_char then
      local backslash_count = 0
      local cursor = index - 1
      while cursor >= 1 and line:sub(cursor, cursor) == "\\" do
        backslash_count = backslash_count + 1
        cursor = cursor - 1
      end

      if backslash_count % 2 == 0 then
        local end_col = index
        if col >= start_col and col <= end_col then
          return line:sub(start_col + 1, end_col - 1)
        end
        start_col = nil
        quote_char = nil
      end
    end

    index = index + 1
  end

  return nil
end

return M
