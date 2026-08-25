local utils = require("config.utils")

local MAX_PARALLEL_SECTIONS = 3

local resolve_languages = function(text)
  if vim.fn.match(text, "[ぁ-んァ-ヶ一-龥]") >= 0 then
    return "Japanese", "English"
  end

  return "English", "Japanese"
end

local split_markdown_sections = function(text)
  local sections = {}
  local section_lines = {}
  local fence_marker
  local backtick = string.char(96)

  local flush_section = function()
    if #section_lines == 0 then
      return
    end

    table.insert(sections, table.concat(section_lines, "\n"))
    section_lines = {}
  end

  for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
    local marker = line:match("^%s*(" .. backtick .. backtick .. backtick .. "+)") or line:match("^%s*(~~~+)")
    if marker then
      local marker_type = marker:sub(1, 1)
      if not fence_marker then
        fence_marker = marker_type
      elseif fence_marker == marker_type then
        fence_marker = nil
      end
    end

    local indentation, heading = line:match("^( *)(#+)%s+")
    local starts_section = heading and #indentation <= 3 and #heading <= 6
    if not fence_marker and starts_section and #section_lines > 0 then
      flush_section()
    end

    table.insert(section_lines, line)
  end

  flush_section()
  return sections
end

local stop_translation_jobs = function(job_state)
  if not job_state or not job_state.job_ids then
    return
  end

  for job_id in pairs(job_state.job_ids) do
    vim.fn.jobstop(job_id)
  end
  job_state.job_ids = {}
end

local start_translation_job = function(text, source_language, target_language, callback, job_state)
  local output = { "" }
  local job_id = vim.fn.jobstart({
    "plamo-translate",
    "--from",
    source_language,
    "--to",
    target_language,
    "--input",
    text,
  }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        output[#output] = output[#output] .. data[1]
        for index = 2, #data do
          table.insert(output, data[index])
        end
      end
    end,
    on_exit = function(completed_job_id, exit_code)
      if job_state and job_state.job_ids then
        job_state.job_ids[completed_job_id] = nil
      end

      if job_state and job_state.cancelled then
        callback(nil)
      elseif exit_code ~= 0 then
        vim.notify("Translation failed", vim.log.levels.ERROR)
        callback(nil)
      else
        callback(vim.trim(table.concat(output, "\n")))
      end
    end,
  })

  if job_state then
    job_state.job_ids = job_state.job_ids or {}
    job_state.job_ids[job_id] = true
  end
  return job_id
end

local translate_async = function(text, callback, job_state)
  if vim.fn.executable("plamo-translate") ~= 1 then
    vim.notify("plamo-translate not found", vim.log.levels.ERROR)
    callback(nil)
    return
  end

  local source_language, target_language = resolve_languages(text)
  return start_translation_job(text, source_language, target_language, callback, job_state)
end

local translate_buffer_async = function(text, callback, job_state, on_progress)
  if vim.fn.executable("plamo-translate") ~= 1 then
    vim.notify("plamo-translate not found", vim.log.levels.ERROR)
    callback(nil)
    return
  end

  local source_language, target_language = resolve_languages(text)
  local sections = split_markdown_sections(text)
  local results = {}
  local completed = 0
  local next_index = 1
  local running = 0
  local finished = false
  local start_next_sections

  job_state.job_ids = {}
  on_progress(completed, #sections)

  start_next_sections = function()
    while not finished and running < MAX_PARALLEL_SECTIONS and next_index <= #sections do
      local section_index = next_index
      next_index = next_index + 1
      running = running + 1

      start_translation_job(sections[section_index], source_language, target_language, function(result)
        running = running - 1
        if finished or job_state.cancelled then
          return
        end

        if not result then
          finished = true
          stop_translation_jobs(job_state)
          callback(nil)
          return
        end

        results[section_index] = result
        completed = completed + 1
        on_progress(completed, #sections)
        if completed == #sections then
          finished = true
          callback(table.concat(results, "\n\n"))
        else
          start_next_sections()
        end
      end, job_state)
    end
  end

  start_next_sections()
end

local show_result_buffer = function(source_text, show_source)
  if show_source then
    vim.cmd("new")
  else
    vim.cmd("rightbelow vnew")
  end

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
  local result_buffer = { buf = buf, win = win, job_ids = {} }
  vim.keymap.set("n", "q", function()
    result_buffer.cancelled = true
    stop_translation_jobs(result_buffer)

    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, silent = true })

  return result_buffer
end

local update_result_buffer = function(result_buffer, content, copyable)
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

  if not copyable then
    return
  end

  vim.keymap.set("n", "y", function()
    vim.fn.setreg("+", content)
    vim.api.nvim_win_close(result_buffer.win, true)
    vim.notify("Copied to clipboard", vim.log.levels.INFO)
  end, { buffer = result_buffer.buf, silent = true })
end

vim.api.nvim_create_user_command("Translate", function(opts)
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local translate_buffer = opts.range == 0
  if not translate_buffer then
    text = utils.get_visual_text()
  end

  if text == "" then
    vim.notify("No text to translate", vim.log.levels.WARN)
    return
  end

  local result_buffer = show_result_buffer(text, not translate_buffer)
  local on_result = function(result)
    vim.schedule(function()
      if result then
        update_result_buffer(result_buffer, result, true)
      elseif vim.api.nvim_win_is_valid(result_buffer.win) then
        vim.api.nvim_win_close(result_buffer.win, true)
      end
    end)
  end

  if not translate_buffer then
    translate_async(text, on_result, result_buffer)
    return
  end

  translate_buffer_async(text, on_result, result_buffer, function(completed, section_count)
    vim.schedule(function()
      local progress = string.format("翻訳中... (%d/%dセクション)", completed, section_count)
      update_result_buffer(result_buffer, progress, false)
    end)
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
