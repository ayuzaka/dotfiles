vim.api.nvim_create_user_command("CopyFile", function()
    vim.fn.setreg("*", vim.fn.expand("%:t"))
end, {})

vim.api.nvim_create_user_command("CopyFullPath", function()
    vim.fn.setreg("*", vim.fn.expand("%:p"))
end, {})

vim.api.nvim_create_user_command("CopyPath", function()
    vim.fn.setreg("*", vim.fn.fnamemodify(vim.fn.expand("%"), ":~:."))
end, {})

vim.api.nvim_create_user_command("RemoveBlankLines", "%v/\\S/d", {})

vim.keymap.set("n", "b,", ":bprev<CR>", { silent = true })
vim.keymap.set("n", "b.", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "bd", ":bd<CR>", {})

local function get_current_latest_blame_hash()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local blame = vim.fn.system(string.format("git blame -L %d,%d %s", line, line, file))

  return vim.split(blame, "\n")[1]:match("^(%x+)")
end

local function run_open_pr_current_line()
  local hash = get_current_latest_blame_hash()
  vim.fn.system("git rev-parse " .. hash .. " | xargs gh openpr")
end

vim.api.nvim_create_user_command("OpenPRCurrentLine", run_open_pr_current_line, {})

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
        vim.api.nvim_err_writeln("No matching buffer for " .. buffer)
        return
    end

    local last_buffer = vim.fn.bufnr("$")
    local delete_count = 0

    for n = 1, last_buffer do
        if n ~= current_buffer and vim.fn.buflisted(n) == 1 then
            if bang == "" and vim.fn.getbufvar(n, "&modified") == 1 then
                vim.api.nvim_err_writeln("No write since last change for buffer "
                    .. n .. " (add ! to override)")
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

local function git_browse_current()
    local dir_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
    vim.fn.system("gh browse " .. dir_path)
end

vim.api.nvim_create_user_command("GitBrowse", git_browse_current, {})

vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    vim.ui.open(cfile)
  else
    vim.cmd("normal! gF")
  end
end)
