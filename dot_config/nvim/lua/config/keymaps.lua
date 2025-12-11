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
vim.keymap.set("n", "<leader>e", ":Filer<CR>", { silent = true })

-- editprompt
-- Send buffer content while keeping the editor open
if vim.env.EDITPROMPT then
    vim.keymap.set("n", "<Space>x", function()
        vim.cmd("update")
        -- Get buffer content
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local content = table.concat(lines, "\n")

        -- Execute editprompt command
        vim.system(
            { "editprompt", "--", content },
            { text = true },
            function(obj)
                vim.schedule(function()
                    if obj.code == 0 then
                        -- Clear buffer on success
                        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
                        vim.cmd("silent write")
                    else
                        -- Show error notification
                        vim.notify("editprompt failed: " .. (obj.stderr or "unknown error"), vim.log.levels.ERROR)
                    end
                end)
            end
        )
    end, { silent = true, desc = "Send buffer content to editprompt" })
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

-- バッファ全体をクリップボードにコピーして、保存せずに終了します
vim.keymap.set("n", "<Leader>Q", ":silent! %y+ | %delete _<CR>", {
  noremap = true,
  desc = "Copy buffer to clipboard and clear buffer",
})


