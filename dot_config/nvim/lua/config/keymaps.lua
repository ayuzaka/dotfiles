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
