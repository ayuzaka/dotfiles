local utils = require("config.utils")

local translate_async = function(text, callback)
  if vim.fn.executable("plamo-translate") ~= 1 then
    vim.notify("plamo-translate not found", vim.log.levels.ERROR)
    callback(nil)
    return
  end

  local output = {}
  vim.fn.jobstart({ "plamo-translate", "--input", text }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        output = data
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("Translation failed", vim.log.levels.ERROR)
        callback(nil)
      else
        local result = vim.trim(table.concat(output, "\n"))
        callback(result)
      end
    end,
  })
end

local show_result_buffer = function(source_text, show_source)
  vim.cmd("new")

  local buf = vim.api.nvim_get_current_buf()
  local lines = { "翻訳中..." }
  if show_source then
    lines = { "原文:", "" }
    vim.list_extend(lines, vim.split(source_text, "\n"))
    vim.list_extend(lines, { "", "英訳:", "", "翻訳中..." })
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  local win = vim.api.nvim_get_current_win()
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, silent = true })

  return { buf = buf, win = win }
end

local update_result_buffer = function(result_buffer, content)
  if not vim.api.nvim_buf_is_valid(result_buffer.buf) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(result_buffer.buf, 0, -1, false)
  local translation_start = 1
  for index, line in ipairs(lines) do
    if line == "英訳:" then
      translation_start = index + 2
      break
    end
  end

  local translated_lines = vim.split(content, "\n")
  for index = #lines, translation_start, -1 do
    table.remove(lines, index)
  end
  vim.list_extend(lines, translated_lines)

  vim.bo[result_buffer.buf].modifiable = true
  vim.api.nvim_buf_set_lines(result_buffer.buf, 0, -1, false, lines)
  vim.bo[result_buffer.buf].modifiable = false

  vim.keymap.set("n", "y", function()
    vim.fn.setreg("+", content)
    vim.api.nvim_win_close(result_buffer.win, true)
    vim.notify("Copied to clipboard", vim.log.levels.INFO)
  end, { buffer = result_buffer.buf, silent = true })
end

vim.api.nvim_create_user_command("Translate", function(opts)
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  if opts.range > 0 then
    text = utils.get_visual_text()
  end

  if text == "" then
    vim.notify("No text to translate", vim.log.levels.WARN)
    return
  end

  local result_buffer = show_result_buffer(text, opts.range > 0)
  translate_async(text, function(result)
    if result then
      vim.schedule(function()
        update_result_buffer(result_buffer, result)
      end)
    else
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(result_buffer.win) then
          vim.api.nvim_win_close(result_buffer.win, true)
        end
      end)
    end
  end)
end, { range = true })

vim.api.nvim_create_user_command("TranslateReplace", function()
  local text = utils.get_visual_text()
  if text == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]
  local buf = vim.api.nvim_get_current_buf()

  vim.notify("Translating...", vim.log.levels.INFO)

  translate_async(text, function(result)
    if result then
      vim.schedule(function()
        vim.api.nvim_buf_set_text(
          buf,
          start_line - 1,
          start_col - 1,
          end_line - 1,
          end_col,
          vim.split(result, "\n")
        )
        vim.notify("Translated", vim.log.levels.INFO)
      end)
    end
  end)
end, { range = true })

vim.keymap.set("v", "<leader>tr", ":Translate<CR>", { silent = true, desc = "Translate selection" })
vim.keymap.set("v", "<leader>tR", ":TranslateReplace<CR>", { silent = true, desc = "Translate and replace" })
