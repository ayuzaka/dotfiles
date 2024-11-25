local opt = vim.opt

-- 文字コードの設定
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileencodings = "ucs-boms,utf-8,euc-jp,cp932"
opt.fileformats = "unix,dos,mac"
opt.ambiwidth = "double"

-- 基本設定
opt.statusline = "%F"
opt.history = 200
opt.backup = false
opt.swapfile = false
opt.autoread = true
opt.hidden = true
opt.showcmd = true
opt.cursorline = true

-- カーソル移動と表示の設定
opt.virtualedit = "onemore"
opt.smartindent = true
opt.showmatch = true

-- matchit.vimの読み込み
vim.cmd([[source $VIMRUNTIME/macros/matchit.vim]])

-- ワイルドメニューの設定
opt.wildmenu = true
opt.wildmode = "full"

-- 表示関連の設定
opt.wrap = true
opt.list = true
opt.listchars = {
  tab = "»-",
  trail = "-",
  extends = "»",
  precedes = "«",
  nbsp = "%"
}

-- その他の設定
opt.belloff = "all"
opt.hlsearch = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.incsearch = true
opt.signcolumn = "yes"
opt.backspace = "indent,eol,start"
opt.re = 0
opt.spell = false
opt.foldmethod = "syntax"
opt.foldlevelstart = 99

opt.syntax = "on"

-- ファイルタイプの設定
vim.cmd("filetype plugin indent on")

-- matchit.vimの読み込み
vim.cmd("runtime macros/matchit.vim")

-- 全角スペースの可視化
vim.api.nvim_create_augroup("highlightIdeographicSpace", { clear = true })
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    group = "highlightIdeographicSpace",
    callback = function()
        vim.api.nvim_set_hl(0, "IdeographicSpace", {
            underline = true,
            bg = "DarkGreen"
        })
    end,
})
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
    group = "highlightIdeographicSpace",
    callback = function()
        vim.fn.matchadd("IdeographicSpace", "　")
    end,
})

-- InsertLeaveでpasteモードを解除
vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        opt.paste = false
    end,
})

-- .env*ファイルの設定
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = ".env*",
    callback = function()
        opt.filetype = "dotenv"
    end,
})

-- 置換コマンドの省略形
vim.cmd([[
cnoreabbrev <expr> s getcmdtype() .. getcmdline() ==# ":s" ? [getchar(), ""][1] .. "%s///g<Left><Left>" : "s"
]])

-- netrwの設定
vim.g.netrw_home = vim.env.XDG_CACHE_HOME .. "/vim"
