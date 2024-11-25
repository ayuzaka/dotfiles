vim.fn["ddu#custom#patch_global"]({
    ui = "ff",
    uiParams = {
        ff = {
            ignoreEmpty = true
        }
    },
    sourceOptions = {
        ["_"] = {
            matchers = {"matcher_substring"},
            ignoreCase = true
        }
    },
    kindOptions = {
        file = {
            defaultAction = "open"
        }
    }
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "ddu-ff",
    callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "<CR>",
            "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
        vim.keymap.set("n", "<Space>",
            "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
        vim.keymap.set("n", "i",
            "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
        vim.keymap.set("n", "p",
            "<Cmd>call ddu#ui#do_action('preview')<CR>", opts)
        vim.keymap.set("n", "q",
            "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "ddu-ff-filter",
    callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("i", "<CR>",
            "<Esc><Cmd>close<CR>", opts)
        vim.keymap.set("n", "<CR>",
            "<Cmd>close<CR>", opts)
        vim.keymap.set("n", "q",
            "<Cmd>close<CR>", opts)
    end
})
