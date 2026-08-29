vim.cmd [[ colorscheme mini.colorscheme ]]

vim.g.mapleader           = " "
vim.g.netrw_sort_sequence = "[/]$"
vim.g.netrw_liststyle     = 3
vim.g.netrw_winsize       = -30
vim.g.netrw_banner        = false
vim.g.c_syntax_for_h      = true

vim.opt.colorcolumn       = "80"
vim.opt.completeopt       = "menuone,noinsert,popup"
vim.opt.signcolumn        = "yes"
vim.opt.wildignore        = "*.o"
vim.opt.pumheight         = 20
vim.opt.shiftwidth        = 4
vim.opt.tabstop           = 4
vim.opt.cursorline        = true
vim.opt.expandtab         = true
vim.opt.ignorecase        = true
vim.opt.number            = true
vim.opt.relativenumber    = true
vim.opt.termguicolors     = true
vim.opt.undofile          = true
vim.opt.showcmd           = false
vim.opt.showmode          = false
vim.opt.wrap              = false

vim.keymap.set("i", "<C-Space>", "<C-x><C-o>")
vim.keymap.set("n", "<Leader>e", ":e **/*")
vim.keymap.set("n", "<Leader>q", ":Lexplore<CR>")

local components = {
    "mini.indentation",
    "mini.status",
    "mini.utilities"
}

for index, component in ipairs(components)
do
    require(component).execute()
end
