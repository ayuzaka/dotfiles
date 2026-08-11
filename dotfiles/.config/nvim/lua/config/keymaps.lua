vim.keymap.set({ "n", "v", "o" }, "<C-]>", "<Esc>")
vim.keymap.set({ "i", "c" }, "<C-]>", "<Esc>")

-- 折り返し時の移動を表示行単位に
vim.keymap.set("n", "j", "gj", { silent = true })
vim.keymap.set("n", "k", "gk", { silent = true })

-- 検索ハイライトを消去
vim.keymap.set("n", "<C-l>", ":nohlsearch<CR><C-l>", { silent = true })

-- 行末までコピー
vim.keymap.set("n", "Y", "y$", { silent = true })

-- リドゥ
vim.keymap.set("n", "U", "<C-r>", { silent = true })

-- 連続インデント操作
vim.keymap.set("x", "<", "<gv", { silent = true })
vim.keymap.set("x", ">", ">gv", { silent = true })

-- a" の時に周囲の空白を巻き込まないようにする
vim.keymap.set("x", "a\"", "2i\"", { silent = true })
vim.keymap.set("x", "a'", "2i'", { silent = true })
vim.keymap.set("x", "a`", "2i`", { silent = true })

vim.keymap.set("o", "a\"", "2i\"", { silent = true })
vim.keymap.set("o", "a'", "2i'", { silent = true })
vim.keymap.set("o", "a`", "2i`", { silent = true })

if vim.g.neovide then
  vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
  vim.keymap.set('v', '<D-c>', '"+y') -- Copy
  vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
  vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
  vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode
end

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap('', '<D-v>', '+p<CR>', { noremap = true, silent = true})
vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+', { noremap = true, silent = true})
vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+', { noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+', { noremap = true, silent = true})

vim.keymap.set("n", "<leader>gs", ":GitStatus<CR>", { silent = true })
vim.keymap.set("n", "<leader>gb", ":GitBlame<CR>", { silent = true })
vim.keymap.set("n", "<leader>gh", ":FileHistory<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", ":Filer<CR>", { silent = true })

-- editprompt
-- Send buffer content while keeping the editor open
if vim.env.EDITPROMPT then
    local sending = false

    if vim.env.EDITPROMPT_WEZTERM_TARGET_PANE and vim.env.WEZTERM_PANE then
        local pane_dir = vim.env.XDG_CACHE_HOME .. "/editprompt"
        vim.fn.mkdir(pane_dir, "p")
        vim.fn.writefile(
            { vim.env.WEZTERM_PANE },
            pane_dir .. "/wezterm-pane-" .. vim.env.EDITPROMPT_WEZTERM_TARGET_PANE
        )
    end

    local function send_editprompt(buffer)
        if sending then
            return
        end

        local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
        local content = table.concat(lines, "\n")
        if vim.trim(content) == "" then
            return
        end

        sending = true
        vim.system(
            { "editprompt", "input", "--", content },
            { text = true },
            function(obj)
                vim.schedule(function()
                    if obj.code == 0 then
                        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
                        vim.api.nvim_buf_call(buffer, function()
                            vim.cmd("silent write")
                        end)
                    else
                        vim.notify("editprompt failed: " .. (obj.stderr or "unknown error"), vim.log.levels.ERROR)
                    end
                    sending = false
                end)
            end
        )
    end

    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = 0,
        callback = function(args)
            send_editprompt(args.buf)
        end,
    })

    vim.keymap.set("n", "<Space>x", "<Cmd>update<CR>", {
        silent = true,
        desc = "Send buffer content to editprompt",
    })
end

vim.keymap.set("n", "b,", ":bprev<CR>", { silent = true })
vim.keymap.set("n", "b.", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "bd", ":bd<CR>", {})
vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    vim.ui.open(cfile)
  else
    vim.cmd("normal! gF")
  end
end)
