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
                            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
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
        opts = {
            css = true,
            tailwind = true,
        },
    },

    -- Zen mode
    {
        "folke/zen-mode.nvim",
        keys = {
            { "<S-z>", "<cmd>ZenMode<CR>", desc = "Toggle Zen Mode", silent = true },
        },
        opts = {},
    },

    -- Buffer manager
    {
        "j-morano/buffer_manager.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            {
                "bl",
                function()
                    require("buffer_manager.ui").toggle_quick_menu()
                end,
                desc = "Buffer list",
                silent = true,
            },
            {
                "<leader>bd",
                function()
                    local bufnr = vim.fn.bufnr("%")
                    if bufnr ~= -1 then
                        vim.cmd(":Bdelete")
                    else
                        print("Invalid buffer number")
                    end
                end,
                desc = "Delete buffer",
                silent = true,
            },
            {
                "<leader>bw",
                function()
                    local bufnr = vim.fn.bufnr("%")
                    if bufnr ~= -1 then
                        vim.cmd(":Bwipeout")
                    else
                        print("Invalid buffer number")
                    end
                end,
                desc = "Wipeout buffer",
                silent = true,
            },
            {
                "bwa",
                function()
                    local buffers = vim.api.nvim_list_bufs()
                    for _, bufnr in ipairs(buffers) do
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

    -- Better buffer deletion
    {
        "moll/vim-bbye",
        cmd = { "Bdelete", "Bwipeout" },
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
        lazy = true,
    },
}
