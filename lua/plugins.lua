local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local env_utils = require("utils.env")
local env = env_utils.Load_env() or {}

require("lazy").setup({
    -- Buffer Manager
    { "j-morano/buffer_manager.nvim", dependencies = {
        "nvim-lua/plenary.nvim",
    } },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", event = "VeryLazy" },
    },
    -- File icons
    { "nvim-tree/nvim-web-devicons", event = "VeryLazy" },
    -- Color highlighter
    { "norcalli/nvim-colorizer.lua", event = "VeryLazy" },
    -- Automatically close HTML tags
    { "alvan/vim-closetag", event = "VeryLazy" },
    { "nvzone/showkeys", cmd = "ShowkeysToggle", opts = { position = "top-right" } },
    -- Surround selections
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    -- Smear effect on cursor
    --{
    --    "sphamba/smear-cursor.nvim",
    --    opts = {},
    --},
    {
        "nvim-pack/nvim-spectre",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("spectre").setup({
                find_engine = {
                    ["rg"] = {
                        cmd = "rg",
                        args = {
                            "--color=never",
                            "--no-heading",
                            "--with-filename",
                            "--line-number",
                            "--column",
                            "--fixed-strings",
                        },
                    },
                },
            })
        end,
    },
    -- Better Yank
    {
        "gbprod/yanky.nvim",
    },
    -- vim notify
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup({
                -- Optional settings
                stages = "fade_in_slide_out", -- Animation style
                timeout = 3000, -- Notification duration in milliseconds
                background_colour = "#000000", -- Adjust for visibility on your theme
                render = "default", -- Rendering style
                minimum_width = 50, -- Minimum width of notification window
                merge_duplicates = true,
            })
            -- Replace vim.notify with nvim-notify
            vim.notify = require("notify")
        end,
    },

    -- Upload, download, and diff files or directories between your local workspace and remote servers via rsync and OpenSSH
    {
        "coffebar/transfer.nvim",
        lazy = true,
        cmd = {
            "TransferInit",
            "DiffRemote",
            "TransferUpload",
            "TransferDownload",
            "TransferDirDiff",
            "TransferRepeat",
        },
        opts = {},
    },
    {
        "stevearc/oil.nvim",
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    -- Git integration
    { "lewis6991/gitsigns.nvim", event = "VeryLazy" },
    {
        "NeogitOrg/neogit",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = true,
    },

    -- Package management
    { "williamboman/mason.nvim", event = "VeryLazy" },
    { "williamboman/mason-lspconfig.nvim", event = "VeryLazy" },
    -- Fuzzy finder and picker
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        event = "VeryLazy",
        dependencies = { { "nvim-lua/plenary.nvim", event = "VeryLazy" } },
    },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", event = "VeryLazy" },
    { "nvim-telescope/telescope-project.nvim", event = "VeryLazy" },
    {
        "FabianWirth/search.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
    -- Move Line and Blocks
    { "booperlv/nvim-gomove", event = "VeryLazy" },
    -- Navigation
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    { -- highlighting for harpoon
        "letieu/harpoon-lualine",
        event = "VeryLazy",
        dependencies = {
            {
                "ThePrimeagen/harpoon",
                branch = "harpoon2",
            },
        },
    },

    -- Floating windows for goto
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        event = "BufEnter",
        config = true,
    },

    -- Better marks
    {
        "chentoast/marks.nvim",
        event = "VeryLazy",
        opts = {},
    },
    -- Move on line by unique letters
    {
        "jinh0/eyeliner.nvim",
        event = "VeryLazy",
    },
    -- Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            local ts_update = require("nvim-treesitter.install").update({
                with_sync = true,
            })
            ts_update()
        end,
        event = "VeryLazy",
    },
    -- Zen mode
    { "folke/zen-mode.nvim", event = "VeryLazy" },
    -- Theme Picker
    { "zaldih/themery.nvim", event = "VeryLazy" },
    -- Themes
    {
        "sanzharkuandyk/nagisa.nvim",
        config = function()
            require("nagisa").setup({})
        end,
    },
    { "dasupradyumna/midnight.nvim", event = "VeryLazy" },
    { "folke/twilight.nvim", event = "VeryLazy" },
    { "famiu/bufdelete.nvim", event = "VeryLazy" },
    -- Linting
    { "mfussenegger/nvim-lint", event = "VeryLazy" },
    -- Formatting
    { "stevearc/conform.nvim", event = "VeryLazy" },
    -- Autopairs
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },
    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = {
            "saghen/blink.cmp",
            event = "VeryLazy",
            {
                "folke/lazydev.nvim",
                event = "VeryLazy",
                ft = "lua",
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
    },
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        config = function()
            require("fidget").setup({})
        end,
    },
    {
        "folke/trouble.nvim",
        event = "VeryLazy",
        cmd = { "Trouble", "TroubleToggle" },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        },
    },
    -- Display prettier diagnostic messages
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        config = function()
            require("tiny-inline-diagnostic").setup()
        end,
    },
    -- Debug Adapter Protocol (DAP)
    { "mfussenegger/nvim-dap", event = "VeryLazy" },
    -- New Completion Setup (blink-cmp)
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = "VeryLazy",
        version = "*",

        opts = {
            keymap = { preset = "default" },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" },

            signature = { enabled = true },

            completion = {
                keyword = { range = "full" },

                trigger = {
                    prefetch_on_insert = true,
                    show_on_keyword = true,
                },

                documentation = { auto_show = true, auto_show_delay_ms = 500 },

                menu = {
                    -- Don't automatically show the completion menu
                    auto_show = true,

                    -- nvim-cmp style menu
                    draw = {
                        columns = {
                            { "label", "label_description", gap = 1 },
                            { "kind_icon", "kind", gap = 2 },
                        },
                    },
                },

                -- Display a preview of the selected item on the current line
                ghost_text = { enabled = true },
            },

            cmdline = {
                completion = { menu = { auto_show = true } },
            },
        },

        opts_extend = { "sources.default" },
    },

    -- Rust support
    { "mrcjkb/rustaceanvim", version = "^6", lazy = false },
    -- TypeScript support
    {
        "pmizio/typescript-tools.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },
    -- Commands work with Russian keyboard layout
    { "powerman/vim-plugin-ruscmd", event = "VeryLazy" },
    -- Markdown preview
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        event = "VeryLazy",
    },
    -- Devicons
    { "ryanoasis/vim-devicons", event = "VeryLazy" },
    -- Toggl Track
    --{
    --    "sanzharkuandyk/toggl-track.nvim",
    --    config = function()
    --        require("toggl-track").setup({
    --            api_token = env.TOGGL_API_TOKEN,
    --            picker = "telescope",
    --        })
    --    end,
    --    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    --},

    -- Disable some rtp plugins
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tohtml",
                "tarPlugin",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
