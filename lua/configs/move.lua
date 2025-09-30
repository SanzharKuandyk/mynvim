require("gomove").setup({
    map_defaults = false, -- disable default keymaps
    reindent = true,
    undojoin = true,
    move_past_end_col = false,
})

local opts = { noremap = true, silent = true }

-- Normal mode move
vim.keymap.set("n", "<C-A-h>", "<Plug>GoNSMLeft", opts)
vim.keymap.set("n", "<C-A-j>", "<Plug>GoNSMDown", opts)
vim.keymap.set("n", "<C-A-k>", "<Plug>GoNSMUp", opts)
vim.keymap.set("n", "<C-A-l>", "<Plug>GoNSMRight", opts)

-- Visual mode move
vim.keymap.set("x", "<C-A-h>", "<Plug>GoVSMLeft", opts)
vim.keymap.set("x", "<C-A-j>", "<Plug>GoVSMDown", opts)
vim.keymap.set("x", "<C-A-k>", "<Plug>GoVSMUp", opts)
vim.keymap.set("x", "<C-A-l>", "<Plug>GoVSMRight", opts)

-- Normal mode duplicate (leader-based)
vim.keymap.set("n", "<leader>mh", "<Plug>GoNSDLeft", opts)
vim.keymap.set("n", "<leader>mj", "<Plug>GoNSDDown", opts)
vim.keymap.set("n", "<leader>mk", "<Plug>GoNSDUp", opts)
vim.keymap.set("n", "<leader>ml", "<Plug>GoNSDRight", opts)

-- Visual mode duplicate (leader-based)
vim.keymap.set("x", "<leader>mh", "<Plug>GoVSDLeft", opts)
vim.keymap.set("x", "<leader>mj", "<Plug>GoVSDDown", opts)
vim.keymap.set("x", "<leader>mk", "<Plug>GoVSDUp", opts)
vim.keymap.set("x", "<leader>ml", "<Plug>GoVSDRight", opts)
