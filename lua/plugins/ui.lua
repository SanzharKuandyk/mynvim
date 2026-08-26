return {
    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", "letieu/harpoon-lualine" },
        event = "VeryLazy",
        opts = {
            options = {
                icons_enabled = true,
                theme = "nagisa",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {
                        "neo-tree",
                    },
                    winbar = {
                        "neo-tree",
                    },
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = {
                    "filename",
                    "harpoon2",
                    {
                        function()
                            return require("shunpo").lualine({
                                fallback = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
                            })
                        end,
                        icon = "",
                        separator = "",
                    },
                },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {},
        },
    },

    -- Notification manager
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            vim.notify = require("notify")

            require("notify").setup({
                background_colour = "#000000",
            })
        end,
    },

    -- Color highlighter
    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        config = function()
            require("colorizer").setup({
                options = { parsers = { css = true } },
            })
        end,
    },

    -- Centered layout
    {
        "shortcuts/no-neck-pain.nvim",
        lazy = false,
        keys = {
            { "<leader>z", "<cmd>NoNeckPain<CR>", desc = "Toggle centering", silent = true },
        },
        opts = {
            width = 120,
            autocmds = {
                enableOnVimEnter = "safe",
            },
        },
    },

    -- Local, dependency-free buffer picker
    {
        "SanzharKuandyk/bufdeck.nvim",
        config = function()
            require("bufdeck").setup({
                keymap = "bl",
                min_width = 0.55,
                max_width = 0.55,
                min_height = 0.4,
                max_height = 0.4,
                save_on_close = true,
                sort = "lastused", -- "lastused", "name", or "bufnr"
                border = "rounded",
                mappings = {
                    open = { "<CR>", "<C-m>" },
                    close = "q",
                    discard = "<Esc>",
                    save = "<C-s>",
                },
            })
        end,
    },

    -- Better buffer deletion
    {
        "moll/vim-bbye",
        cmd = { "Bdelete", "Bwipeout" },
        keys = {
            { "<leader>bd", "<cmd>Bdelete<CR>", desc = "Delete buffer", silent = true },
            { "<leader>bw", "<cmd>Bwipeout<CR>", desc = "Wipeout buffer", silent = true },
            {
                "bwa",
                function()
                    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                        if
                            vim.api.nvim_buf_is_valid(bufnr)
                            and vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
                        then
                            vim.api.nvim_buf_delete(bufnr, { force = true })
                        end
                    end
                end,
                desc = "Wipeout all buffers",
                silent = true,
            },
        },
    },

    -- Show key presses
    {
        "nvzone/showkeys",
        cmd = "ShowkeysToggle",
        opts = {},
    },

    -- Icons
    {
        "nvim-tree/nvim-web-devicons",
        lazy = false, -- Required by Oil.nvim which loads immediately
        priority = 999, -- Load before Oil.nvim
    },
}
