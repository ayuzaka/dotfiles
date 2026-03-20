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

local show_floating_window = function(cursor_pos)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Translating..." })

  local width = 40
  local height = 3
  local row_offset = 1
  local col_offset = 0

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "win",
    win = cursor_pos.win,
    bufpos = { cursor_pos.row - 1, cursor_pos.col - 1 },
    width = width,
    height = height,
    row = row_offset,
    col = col_offset,
    style = "minimal",
    border = "rounded",
  })

  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })

  return { buf = buf, win = win }
end

local update_floating_window = function(float, content)
  if not vim.api.nvim_win_is_valid(float.win) then
    return
  end

  local lines = vim.split(content, "\n")
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end

  local width = math.min(math.max(max_width, 20), 80)
  local height = math.min(#lines, math.floor(vim.o.lines * 0.5))

  vim.bo[float.buf].modifiable = true
  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)
  vim.bo[float.buf].modifiable = false
  vim.api.nvim_win_set_config(float.win, { width = width, height = height })

  vim.keymap.set("n", "y", function()
    vim.fn.setreg("+", content)
    vim.api.nvim_win_close(float.win, true)
    vim.notify("Copied to clipboard", vim.log.levels.INFO)
  end, { buffer = float.buf, silent = true })
end

vim.api.nvim_create_user_command("Translate", function()
  local text = utils.get_visual_text()
  if text == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  local end_pos = vim.fn.getpos("'>")
  local cursor_pos = {
    win = vim.api.nvim_get_current_win(),
    row = end_pos[2],
    col = end_pos[3],
  }

  local float = show_floating_window(cursor_pos)
  translate_async(text, function(result)
    if result then
      vim.schedule(function()
        update_floating_window(float, result)
      end)
    else
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(float.win) then
          vim.api.nvim_win_close(float.win, true)
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
