-- Encoding & UI
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileformats = "unix,dos"
vim.opt.termguicolors = true
vim.o.guifont = "UbuntuSansMono\\ NF:h11"

-- Searching
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Display
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false

-- Indentation
vim.opt.smarttab = true
vim.opt.cindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Behavior
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.updatetime = 650

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Theme settings (colorscheme set after plugins load)
vim.g.nagisa_transparent = false

-- GUI settings
vim.g.airline_powerline_fonts = 1
