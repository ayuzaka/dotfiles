vim.fn["ddc#custom#patch_global"]("ui", "native")

vim.fn["ddc#custom#patch_global"]("sources", { "skkeleton", "vim-lsp" })

vim.fn["ddc#custom#patch_global"]("sourceOptions", {
    ["_"] = {
        matchers = {"matcher_head"},
        sorters = {"sorter_rank"}
    },
    skkeleton = {
        mark = "skkeleton",
        matchers = {},
        sorters = {},
        converters = {},
        isVolatile = true,
        minAutoCompleteLength = 1
    },
    ["vim-lsp"] = {
      matchers = { "matcher_head" },
      mark = "lsp"
    }
})

vim.fn["skkeleton#config"]({
    completionRankFile = "~/.skkeleton/rank.json"
})

vim.keymap.set("i", "<TAB>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    elseif vim.fn.col(".") <= 1 or string.match(vim.fn.getline("."):sub(vim.fn.col(".") - 2, vim.fn.col(".") - 2), "%s") then
        return "<TAB>"
    else
        return vim.fn["ddc#map#manual_complete"]()
    end
end, { expr = true, silent = true })

vim.keymap.set("i", "<S-TAB>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-h>"
end, { expr = true })

vim.fn["ddc#enable"]()
