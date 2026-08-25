package.path = vim.fn.getcwd() .. "/dotfiles/.config/nvim/lua/?.lua;" .. package.path

describe(":Translate", function()
  local executable
  local jobstart

  before_each(function()
    vim.cmd("silent! only!")
    vim.cmd("enew!")

    executable = vim.fn.executable
    jobstart = vim.fn.jobstart
    vim.fn.executable = function()
      return 1
    end

    pcall(vim.api.nvim_del_user_command, "Translate")
    pcall(vim.api.nvim_del_user_command, "TranslateReplace")
  end)

  after_each(function()
    vim.fn.executable = executable
    vim.fn.jobstart = jobstart
    pcall(vim.api.nvim_del_user_command, "Translate")
    pcall(vim.api.nvim_del_user_command, "TranslateReplace")
  end)

  local find_argument = function(command, argument)
    for index, value in ipairs(command) do
      if value == argument then
        return command[index + 1]
      end
    end
  end

  local wait_for_lines = function(expected)
    local completed = vim.wait(1000, function()
      return vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), expected)
    end)

    assert.is_true(completed)
  end

  it("translates all text from a reader mode buffer without dropping output chunks", function()
    local source_lines = { "# Article", "", "First paragraph.", "", "Last paragraph." }
    local translation_command
    vim.api.nvim_buf_set_lines(0, 0, -1, false, source_lines)
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "hide"
    vim.bo.modifiable = false
    vim.bo.readonly = true

    vim.fn.jobstart = function(command, options)
      translation_command = command
      vim.schedule(function()
        options.on_stdout(42, { "最初の" })
        options.on_stdout(42, { "翻訳", "" })
        options.on_stdout(42, { "最後の翻訳", "" })
        options.on_exit(42, 0)
      end)
      return 42
    end

    dofile(vim.fn.getcwd() .. "/dotfiles/.config/nvim/lua/config/commands/translate.lua")
    vim.cmd("Translate")

    wait_for_lines({ "最初の翻訳", "最後の翻訳" })
    assert.are.equal("English", find_argument(translation_command, "--from"))
    assert.are.equal("Japanese", find_argument(translation_command, "--to"))
    assert.are.equal(table.concat(source_lines, "\n"), find_argument(translation_command, "--input"))
  end)

  it("translates Markdown sections concurrently and combines them in source order", function()
    local fence = string.rep(string.char(96), 3)
    local long_paragraph = string.rep("A", 5000)
    local source_lines = {
      "# Article",
      "",
      fence .. "markdown",
      "## Example",
      fence,
      "## First",
      long_paragraph,
      "## Second",
      "Second paragraph.",
      "## Third",
      "Last paragraph.",
    }
    local translation_jobs = {}
    local original_win = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, source_lines)

    vim.fn.jobstart = function(command, options)
      table.insert(translation_jobs, { command = command, options = options })
      return 40 + #translation_jobs
    end

    dofile(vim.fn.getcwd() .. "/dotfiles/.config/nvim/lua/config/commands/translate.lua")
    vim.cmd("Translate")

    assert.are.equal(3, #translation_jobs)
    assert.is_true(vim.api.nvim_win_get_position(0)[2] > vim.api.nvim_win_get_position(original_win)[2])
    local section_inputs = {
      table.concat(vim.list_slice(source_lines, 1, 5), "\n"),
      table.concat(vim.list_slice(source_lines, 6, 7), "\n"),
      table.concat(vim.list_slice(source_lines, 8, 9), "\n"),
      table.concat(vim.list_slice(source_lines, 10, 11), "\n"),
    }
    for index = 1, 3 do
      assert.are.equal(section_inputs[index], find_argument(translation_jobs[index].command, "--input"))
    end

    translation_jobs[3].options.on_stdout(43, { "2番目の翻訳", "" })
    translation_jobs[3].options.on_exit(43, 0)
    assert.are.equal(4, #translation_jobs)
    assert.are.equal(section_inputs[4], find_argument(translation_jobs[4].command, "--input"))
    translation_jobs[4].options.on_stdout(44, { "最後の翻訳", "" })
    translation_jobs[4].options.on_exit(44, 0)
    translation_jobs[1].options.on_stdout(41, { "タイトルの" })
    translation_jobs[1].options.on_stdout(41, { "翻訳", "" })
    translation_jobs[1].options.on_exit(41, 0)
    translation_jobs[2].options.on_stdout(42, { "最初の翻訳", "" })
    translation_jobs[2].options.on_exit(42, 0)

    wait_for_lines({ "タイトルの翻訳", "", "最初の翻訳", "", "2番目の翻訳", "", "最後の翻訳" })
  end)

  it("translates Japanese text to English explicitly", function()
    local translation_command
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "日本語の文章です。" })

    vim.fn.jobstart = function(command, options)
      translation_command = command
      vim.schedule(function()
        options.on_stdout(42, { "This is Japanese text.", "" })
        options.on_exit(42, 0)
      end)
      return 42
    end

    dofile(vim.fn.getcwd() .. "/dotfiles/.config/nvim/lua/config/commands/translate.lua")
    vim.cmd("Translate")

    wait_for_lines({ "This is Japanese text." })
    assert.are.equal("Japanese", find_argument(translation_command, "--from"))
    assert.are.equal("English", find_argument(translation_command, "--to"))
  end)
end)
