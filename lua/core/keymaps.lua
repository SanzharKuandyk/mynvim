-- Mode switch mappings
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("v", "vjk", "<Esc>")
vim.keymap.set("t", "jk", "<C-\\><C-n>")

-- File Saving
vim.keymap.set("n", "<C-s>", ":w<CR>", { noremap = true })

-- Split creation
vim.keymap.set("n", "<leader>dv", ":vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>db", ":split<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>de", ":close<CR>", { noremap = true, silent = true })

-- Resize splits
local function resize_split(direction, amount)
	vim.cmd(direction == "height" and ("resize " .. amount) or ("vertical resize " .. amount))
end

vim.keymap.set("n", "<C-Up>", function()
	resize_split("height", "+5")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-Down>", function()
	resize_split("height", "-5")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-Left>", function()
	resize_split("width", "-5")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-Right>", function()
	resize_split("width", "+5")
end, { noremap = true, silent = true })

-- Split navigation
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })

-- Fast movement
vim.keymap.set("n", "<leader>ls", "^", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>le", "$", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>ls", "^", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>le", "$", { noremap = true, silent = true })
vim.keymap.set("n", "<S-h>", "5h", { noremap = true })
vim.keymap.set("n", "<S-j>", "5j", { noremap = true })
vim.keymap.set("n", "<S-k>", "5k", { noremap = true })
vim.keymap.set("n", "<S-l>", "5l", { noremap = true })

-- Move between errors and search results
vim.keymap.set("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ln", ":lnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lp", ":lprev<CR>", { noremap = true, silent = true })

-- Switch to next buffer/tab
vim.keymap.set("n", "<leader>n", ":bnext<CR>", { noremap = true })
vim.keymap.set("n", "<leader>p", ":bprev<CR>", { noremap = true })
