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

local function is_escaped(line, index)
  local backslash_count = 0
  local cursor = index - 1

  while cursor >= 1 and line:sub(cursor, cursor) == "\\" do
    backslash_count = backslash_count + 1
    cursor = cursor - 1
  end

  return backslash_count % 2 == 1
end

local function get_enclosed_text_under_cursor(line, col)
  local delimiters = {
    ["'"] = { close = "'", kind = "quote" },
    ['"'] = { close = '"', kind = "quote" },
    ["`"] = { close = "`", kind = "quote" },
    ["("] = { close = ")", kind = "pair" },
    ["["] = { close = "]", kind = "pair" },
    ["{"] = { close = "}", kind = "pair" },
    ["<"] = { close = ">", kind = "pair" },
  }
  local closing_to_opening = {
    [")"] = "(",
    ["]"] = "[",
    ["}"] = "{",
    [">"] = "<",
  }
  local candidates = {}
  local stack = {}
  local index = 1
  local line_length = #line

  while index <= line_length do
    local char = line:sub(index, index)
    local current = stack[#stack]

    if current and current.kind == "quote" then
      if char == current.close and not is_escaped(line, index) then
        table.insert(candidates, {
          start_col = current.start_col,
          end_col = index,
        })
        table.remove(stack)
      end
    else
      local delimiter = delimiters[char]
      if delimiter then
        table.insert(stack, {
          close = delimiter.close,
          kind = delimiter.kind,
          open = char,
          start_col = index,
        })
      elseif closing_to_opening[char] then
        local expected_open = closing_to_opening[char]
        if current and current.kind == "pair" and current.open == expected_open then
          table.insert(candidates, {
            start_col = current.start_col,
            end_col = index,
          })
          table.remove(stack)
        end
      end
    end

    index = index + 1
  end

  local best_match = nil
  for _, candidate in ipairs(candidates) do
    if col >= candidate.start_col and col <= candidate.end_col then
      if not best_match then
        best_match = candidate
      else
        local candidate_width = candidate.end_col - candidate.start_col
        local best_width = best_match.end_col - best_match.start_col
        if candidate_width < best_width then
          best_match = candidate
        end
      end
    end
  end

  if not best_match then
    return nil
  end

  return line:sub(best_match.start_col + 1, best_match.end_col - 1)
end

M.get_visual_text = function()
  return get_visual_text_internal({ block_mode = "legacy" })
end

M.get_visual_query_text = function()
  local text = get_visual_text_internal({ block_mode = "strict" })
  return normalize_query_text(text)
end

M.url_encode = function(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

M.get_quoted_text_under_cursor = function(line, col)
  return get_enclosed_text_under_cursor(line, col)
end

M.get_diagnostic_namespace_name = function(diagnostic)
  if type(diagnostic.namespace) ~= "number" then
    return nil
  end

  local ok, namespace = pcall(vim.diagnostic.get_namespace, diagnostic.namespace)
  if not ok or type(namespace) ~= "table" then
    return nil
  end

  if type(namespace.name) ~= "string" or namespace.name == "" then
    return nil
  end

  return namespace.name
end

M.resolve_search_query = function(opts, options)
  if opts.range > 0 then
    local visual_query = M.get_visual_query_text()
    if visual_query ~= "" then
      return visual_query
    end
  end

  if opts.args and opts.args ~= "" then
    return table.concat(opts.fargs, " ")
  end

  if options.get_fallback_query then
    local fallback_query = options.get_fallback_query()
    if fallback_query and fallback_query ~= "" then
      return fallback_query
    end
  end

  if options.prompt then
    local input_query = vim.trim(vim.fn.input(options.prompt))
    if input_query ~= "" then
      return input_query
    end
  end

  vim.notify(options.empty_message or "Search query is empty", vim.log.levels.WARN)
  return nil
end

return M
