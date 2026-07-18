local M = {}

function M.format_result(result, options)
  local lines = { result.query }
  if result.page_title ~= result.query then
    table.insert(lines, "ページ: " .. result.page_title)
  end
  table.insert(lines, "")

  for entry_index, entry in ipairs(result.entries) do
    if entry_index > 1 then
      table.insert(lines, "")
    end

    table.insert(lines, entry.part_of_speech)
    local visible_count = math.min(#entry.definitions, options.max_definitions)
    for definition_index = 1, visible_count do
      table.insert(lines, string.format("%d. %s", definition_index, entry.definitions[definition_index]))
    end

    local omitted_count = #entry.definitions - visible_count
    if omitted_count > 0 then
      table.insert(lines, string.format("…ほか%d件", omitted_count))
    end
  end

  return lines
end

function M.show(result, options)
  local bufnr, winid = vim.lsp.util.open_floating_preview(
    M.format_result(result, options),
    "plaintext",
    {
      border = options.border,
      close_events = {},
      focusable = true,
      max_height = options.max_height,
      max_width = options.max_width,
      wrap = true,
    }
  )

  local function close()
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_win_close(winid, true)
    end
  end

  vim.keymap.set("n", "q", close, { buffer = bufnr, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = bufnr, nowait = true, silent = true })
  vim.api.nvim_set_current_win(winid)

  return bufnr, winid
end

function M.select(candidates, query, callback)
  vim.ui.select(candidates, {
    kind = "wiktionary",
    prompt = "Wiktionaryの候補を選択: " .. query,
  }, callback)
end

function M.notify(message, level)
  vim.notify(message, level)
end

return M
