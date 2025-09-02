local builtin = require("telescope.builtin")
local telescope = require("telescope")

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>fc", builtin.git_status, {})
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, {})

telescope.setup({
    defaults = {
        file_ignore_patterns = {
            "%.uid",
        },
    },
    extensions = {
        fzf = {},
        project = {},
    },
})

-- Keybinding to open Telescope project extension
vim.keymap.set("n", "<leader>fp", function()
    telescope.extensions.project.project()
end, {})

-- Keybinding to open the search plugin's Telescope tabs
vim.keymap.set("n", "<leader>tt", function()
    require("search").open()
end, {})

require("search").setup({
    mappings = { -- optional: configure the mappings for switching tabs (will be set in normal and insert mode(!))
        next = "<Tab>",
        prev = "<S-Tab>",
    },
    append_tabs = { -- append_tabs will add the provided tabs to the default ones
        {
            "Commits", -- or name = "Commits"
            builtin.git_commits, -- or tele_func = require('telescope.builtin').git_commits
            available = function() -- optional
                return vim.fn.isdirectory(".git") == 1
            end,
        },
        {
            "CBFF", -- Fuzzy Finder in current buffer
            builtin.current_buffer_fuzzy_find,
        },
    },
})

telescope.load_extension("fzf")
telescope.load_extension("project")
