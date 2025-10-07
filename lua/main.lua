-- Set encoding to UTF-8
vim.opt.encoding = "UTF-8"
vim.opt.termguicolors = true

vim.o.guifont = "UbuntuSansMono\\ NF:h11"
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.o.wrap = false

-- General Settings
vim.cmd([[
    set number
    set relativenumber
    set smarttab
    set cindent
    set tabstop=2
    set shiftwidth=2
    set expandtab
    set mouse=a
    set noshowmode
    set updatetime=650
    set iskeyword-=_ 
    set encoding=utf-8
    set fileencoding=utf-8
    let mapleader=" "
    inoremap jk <Esc>
    vnoremap vjk <Esc>
    tnoremap jk <C-\><C-n>
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
]])

vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        local cwd = vim.fn.getcwd()
        local cwd_escaped = cwd:gsub("\\", "\\\\")
        vim.cmd('silent! call chansend(v:stderr, "\\033]7;file:///' .. cwd_escaped .. '\\007")')
    end,
})

-- Theme
vim.g.nagisa_transparent = false
vim.cmd.colorscheme("EndOfTheWorld")

-- File Saving
vim.api.nvim_set_keymap("n", "<C-s>", ":w<CR>", { noremap = true })

-- Split creation
vim.api.nvim_set_keymap("n", "<leader>dv", ":vsplit<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>db", ":split<CR>", { noremap = true, silent = true })

-- Close split
vim.api.nvim_set_keymap("n", "<leader>de", ":close<CR>", { noremap = true, silent = true })

function Resize_split(direction, amount)
    vim.cmd(direction == "height" and ("resize " .. amount) or ("vertical resize " .. amount))
end

-- Resize splits
vim.api.nvim_set_keymap("n", "<C-Up>", ":lua Resize_split('height', '+5')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Down>", ":lua Resize_split('height', '-5')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Left>", ":lua Resize_split('width', '-5')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Right>", ":lua Resize_split('width', '+5')<CR>", { noremap = true, silent = true })

-- Split navigation keybindings
vim.api.nvim_set_keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true })
vim.api.nvim_set_keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true })
vim.api.nvim_set_keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true })
vim.api.nvim_set_keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true })

-- Fast movement keybindings
vim.api.nvim_set_keymap("n", "<leader>ls", "^", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>le", "$", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>ls", "^", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>le", "$", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-h>", "5h", { noremap = true })
vim.api.nvim_set_keymap("n", "<S-j>", "5j", { noremap = true })
vim.api.nvim_set_keymap("n", "<S-k>", "5k", { noremap = true })
vim.api.nvim_set_keymap("n", "<S-l>", "5l", { noremap = true })

-- Move between errors and search results
vim.api.nvim_set_keymap("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ln", ":lnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>lp", ":lprev<CR>", { noremap = true, silent = true })

-- Switch to next buffer/tab
vim.api.nvim_set_keymap("n", "<leader>n", ":bnext<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>p", ":bprev<CR>", { noremap = true })

-- Replace character in normal mode without yanking
vim.api.nvim_set_keymap("n", "r", '"_r', { noremap = true })

-- Replace selection in visual mode without yanking
vim.api.nvim_set_keymap("v", "c", '"_c', { noremap = true })
vim.api.nvim_set_keymap("v", "d", '"_d', { noremap = true })

-- Key mappings to zoom in and out
vim.api.nvim_set_keymap("n", "<C-=>", ":lua change_font_size(1)<CR>", { noremap = true, silent = true }) -- Zoom in
vim.api.nvim_set_keymap("n", "<C-->", ":lua change_font_size(-1)<CR>", { noremap = true, silent = true }) -- Zoom out

-- Clipboard settings
vim.opt.clipboard:append("unnamedplus")

-- GUI font settings
vim.g.airline_powerline_fonts = 1

-- ctrlp settings
vim.g.ctrlp_user_command = {
    -- Exclude .git directory
    "rg --files --hidden --iglob !.git",
}

local previous_directory = nil

function OpenConfigFolder()
    previous_directory = vim.fn.getcwd()

    local config_path = vim.fn.stdpath("config")
    vim.cmd("e " .. config_path)
end

function ReturnToPreviousDirectory()
    if previous_directory then
        vim.cmd("e " .. previous_directory)
        previous_directory = nil
    else
        print("No previous directory saved!")
        vim.cmd("echo 'No previous directory saved!'")
    end
end

vim.cmd("command! OpenConfig lua OpenConfigFolder()")
vim.cmd("command! ReturnToPreviousDirectory lua ReturnToPreviousDirectory()")
vim.api.nvim_set_keymap("n", "<leader>oc", ":OpenConfig<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ob", ":ReturnToPreviousDirectory<CR>", { noremap = true, silent = true })
