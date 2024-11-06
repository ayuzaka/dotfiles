vim.g["airline#extensions#tabline#enabled"] = 1
vim.g["airline#extensions#tabline#fnamemod"] = ":t"
vim.g["airline#extensions#tabline#formatter"] = "unique_tail_improved"

vim.g["airline_section_a"] = vim.fn["airline#section#create"]({})
vim.g["airline_section_b"] = vim.fn["airline#section#create"]({})
vim.g["airline_section_x"] = vim.fn["airline#section#create"]({ "tagbar" })
vim.g["airline_section_y"] = vim.fn["airline#section#create"]({})
vim.g["airline_section_z"] = vim.fn["airline#section#create"]({})
