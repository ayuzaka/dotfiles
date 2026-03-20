local M = {}

M.is_cursor_in_diagnostic = function(diagnostic, line, col)
  if diagnostic.lnum > line or diagnostic.end_lnum < line then
    return false
  end

  if diagnostic.lnum == line and diagnostic.col > col then
    return false
  end

  if diagnostic.end_lnum == line and diagnostic.end_col <= col then
    return false
  end

  return true
end

M.format_diagnostic_choice = function(diagnostic)
  local code = type(diagnostic.code) == "string" and diagnostic.code or "unknown-rule"
  local message = diagnostic.message:gsub("%s+", " ")

  return string.format("%s: %s", code, message)
end

return M
