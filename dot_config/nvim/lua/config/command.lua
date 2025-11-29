local function camel_to_kebab_text(text)
  local kebab_text = text:gsub("([A-Z])", function(c)
    return "-" .. c:lower()
  end)

  -- If the text starts with a capital letter, a hyphen will be added to the beginning, so delete it.
  if kebab_text:sub(1, 1) == "-" then
    kebab_text = kebab_text:sub(2)
  end

  return kebab_text
end

local function selected_range_text(opts)
  if opts.range == 0 then
    return nil
  end

  return opts.line1 == opts.line2 and tostring(opts.line1)
      or string.format("%d-%d", opts.line1, opts.line2)
end

vim.api.nvim_create_user_command("CopyFile", function(opts)
  local filename = vim.fn.expand("%:t")
  local range = selected_range_text(opts)
  local text = range and (filename .. ":" .. range) or filename

  vim.fn.setreg("*", text)
end, { range = true })

vim.api.nvim_create_user_command("CopyFileKebab", function()
  local filename = vim.fn.expand("%:t")
  local extension = filename:match("(%.[^.]+)$") or ""
  local basename = filename:gsub(extension, "")
  local kebab_file_name = camel_to_kebab_text(basename)

  vim.fn.setreg("*", kebab_file_name)
end, {})

vim.api.nvim_create_user_command("CopyFullPath", function(opts)
  local path = vim.fn.expand("%:p")
  local range = selected_range_text(opts)
  local text = range and (path .. ":" .. range) or path

  vim.fn.setreg("*", text)
end, { range = true })

vim.api.nvim_create_user_command("CopyPath", function(opts)
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  local range = selected_range_text(opts)
  local text = range and (path .. ":" .. range) or path

  vim.fn.setreg("*", text)
end, { range = true })

vim.api.nvim_create_user_command("CopyBuffer", function()
  vim.cmd([[normal! gg"+yG]])
end, {})

vim.api.nvim_create_user_command("RemoveBlankLines", "%v/\\S/d", {})

vim.keymap.set("n", "b,", ":bprev<CR>", { silent = true })
vim.keymap.set("n", "b.", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "bd", ":bd<CR>", {})

local function search_regex(text)
  vim.fn.histdel("/")
  vim.fn.setreg("/", text)
  vim.fn.histadd("/", vim.fn.getreg("/"))
  vim.cmd("/" .. vim.fn.getreg("/"))
end

vim.api.nvim_create_user_command("SearchFullWidthEn", function()
  search_regex("[Ａ-Ｚａ-ｚ]\\+")
end, {})

vim.api.nvim_create_user_command("SearchFullWidthNum", function()
  search_regex("[０-９]\\+")
end, {})

vim.api.nvim_create_user_command("SearchFullWidthSpace", function()
  search_regex("[　]\\+")
end, {})

vim.api.nvim_create_user_command("SearchFullWidth", function()
  search_regex("[Ａ-Ｚａ-ｚ　０-９]\\+")
end, {})

local function full_to_half()
  local word = vim.fn.expand("<cword>")
  local halfwidth_word = ""

  for char in vim.gsplit(word, "") do
    local code = vim.fn.char2nr(char)
    if code >= 65281 and code <= 65370 then
      halfwidth_word = halfwidth_word .. vim.fn.nr2char(code - 65248)
    else
      halfwidth_word = halfwidth_word .. char
    end
  end

  local cmd = string.format([[substitute/\V\<%s\>/%s/g]], vim.fn.escape(word, "/"), halfwidth_word)
  vim.cmd(cmd)
end

local function half_to_full()
  local word = vim.fn.expand("<cword>")
  local fullwidth_word = ""

  for char in vim.gsplit(word, "") do
    local code = vim.fn.char2nr(char)
    if code >= 33 and code <= 126 then
      fullwidth_word = fullwidth_word .. vim.fn.nr2char(code + 65248)
    else
      fullwidth_word = fullwidth_word .. char
    end
  end

  local cmd = string.format([[substitute/\V\<%s\>/%s/g]], vim.fn.escape(word, "/"), fullwidth_word)
  vim.cmd(cmd)
end

vim.api.nvim_create_user_command("FullToHalf", full_to_half, {})
vim.api.nvim_create_user_command("HalfToFull", half_to_full, {})

local function add_spell(args)
  local word = args.args ~= "" and args.args or vim.fn.expand("<cword>")
  local file = vim.fn.expand("$XDG_DATA_HOME/cspell/dict-custom.txt")

  local f = io.open(file, "a")
  if f then
    f:write(string.lower(word) .. "\n")
    f:close()
    print("Added '" .. word .. "'")
  end
end

vim.api.nvim_create_user_command("SpellAdd", add_spell, { nargs = "?" })

vim.api.nvim_create_user_command("Profile", function()
  vim.cmd("profile start ~/profile.txt")
  vim.cmd("profile func *")
  vim.cmd("profile file *")
end, {})

local function buf_only(buffer, bang)
  local current_buffer = buffer == "" and vim.fn.bufnr("%") or vim.fn.bufnr(buffer)

  if current_buffer == -1 then
    vim.api.nvim_echo({ { "No matching buffer for " .. buffer, "ErrorMsg" } }, true, {})
    return
  end

  local last_buffer = vim.fn.bufnr("$")
  local delete_count = 0

  for n = 1, last_buffer do
    if n ~= current_buffer and vim.fn.buflisted(n) == 1 then
      if bang == "" and vim.fn.getbufvar(n, "&modified") == 1 then
        vim.api.nvim_echo({ { "No write since last change for buffer " .. n .. " (add ! to override)", "ErrorMsg" } },
          true, {})
      else
        vim.cmd("silent bdel" .. bang .. " " .. n)
        if vim.fn.buflisted(n) == 0 then
          delete_count = delete_count + 1
        end
      end
    end
  end

  if delete_count > 0 then
    print(delete_count .. (delete_count == 1 and " buffer" or " buffers") .. " deleted")
  end
end

vim.api.nvim_create_user_command("BufOnly", function(opts)
  buf_only(opts.args, opts.bang and "!" or "")
end, { nargs = "?", bang = true, complete = "buffer" })

vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    vim.ui.open(cfile)
  else
    vim.cmd("normal! gF")
  end
end)

local function open_by_another_editor(command)
  local path = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  vim.fn.system(command .. ' --g ' .. path .. ':' .. line)
end

vim.api.nvim_create_user_command('Cursor', function() open_by_another_editor('cursor') end, { range = true })
vim.api.nvim_create_user_command('Code', function() open_by_another_editor('code') end, { range = true })

local function tabs_to_spaces()
  local original_expandtab = vim.api.nvim_get_option_value("expandtab", { scope = "local" })
  vim.opt_local.expandtab = true
  vim.cmd("retab")
  if not original_expandtab then
    vim.opt_local.expandtab = false
  end
end

vim.api.nvim_create_user_command("TabsToSpaces", tabs_to_spaces, {})

-- preview for glow
vim.api.nvim_create_user_command('Glow', function()
  -- 先に元バッファの絶対パスを取得
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p')
  if path == '' then
    return
  end
  local cwd = vim.fn.fnamemodify(path, ':h')

  -- create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local W, H = math.floor(vim.o.columns * 0.8), math.floor(vim.o.lines * 0.8)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = W,
    height = H,
    col = math.floor((vim.o.columns - W) / 2),
    row = math.floor((vim.o.lines - H) / 2),
    style = 'minimal',
    border = 'rounded',
  })

  -- glow
  vim.fn.jobstart({ 'glow', path }, { cwd = cwd, term = true })

  -- close
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, silent = true })
end, {})

vim.api.nvim_create_user_command("ScratchMD", function()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
end, {})

-- バッファ全体をクリップボードにコピーして、保存せずに終了します
vim.keymap.set("n", "<Leader>Q", ":silent! %y+ | q!<CR>", {
  noremap = true,
  desc = "Copy buffer to clipboard and quit without saving",
})
