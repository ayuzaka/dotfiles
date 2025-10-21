-- 文字コードの設定
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = "ucs-boms,utf-8,euc-jp,cp932"
vim.opt.fileformats = "unix,dos,mac"
vim.opt.ambiwidth = "double"

-- 基本設定
vim.opt.statusline = "%F"
vim.opt.history = 200
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.showcmd = true
vim.opt.cursorline = true

-- カーソル移動と表示の設定
vim.opt.virtualedit = "onemore"
vim.opt.smartindent = true
vim.opt.showmatch = true

-- ワイルドメニューの設定
vim.opt.wildmenu = true
vim.opt.wildmode = "full"

-- 表示関連の設定
vim.opt.wrap = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "»-",
  trail = "-",
  extends = "»",
  precedes = "«",
  nbsp = "%"
}
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }

-- その他の設定
vim.opt.belloff = "all"
vim.opt.hlsearch = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.backspace = "indent,eol,start"
vim.opt.re = 0
vim.opt.spell = false
vim.opt.foldmethod = "manual"
vim.cmd([[ set nofoldenable ]])

vim.opt.syntax = "on"

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
    vim.opt.paste = false
  end,
})

-- 置換コマンドの省略形
vim.cmd([[
cnoreabbrev <expr> s getcmdtype() .. getcmdline() ==# ":s" ? [getchar(), ""][1] .. "%s///g<Left><Left>" : "s"
]])

-- netrwの設定
vim.g.netrw_home = vim.env.XDG_CACHE_HOME .. "/nvim"

-- :term でカーソルがずれる問題の解消
vim.api.nvim_create_autocmd("TermOpen", {
pattern = "*",
callback = function()
  vim.opt_local.ambiwidth = "single"
  end,
})

vim.filetype.add({
  pattern = {
    ['.env.*'] = 'dotenv'
  }
})

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

-- In your Neovim config (e.g., init.lua)
if vim.env.EDITPROMPT then
  vim.opt.wrap = true
  -- Load a specific colorscheme
  vim.cmd('colorscheme habamax')
end
