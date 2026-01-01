return {
    -- Treesitter: syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.install").compilers = { "gcc" }
            require("nvim-treesitter.configs").setup({
                ignore_install = {},
                ensure_installed = {
                    "c",
                    "cpp",
                    "go",
                    "lua",
                    "rust",
                    "typescript",
                    "cmake",
                    "vue",
                    "html",
                    "css",
                    "javascript",
                    "json",
                    "yaml",
                    "markdown",
                    "graphql",
                    "scss",
                    "gdscript",
                    "godot_resource",
                    "gdshader",
                    "zig",
                },
                modules = {},
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },

    -- Auto tag closing
    {
        "windwp/nvim-ts-autotag",
        event = { "InsertEnter" },
        ft = { "html", "xml", "vue", "tsx", "jsx", "typescriptreact", "javascriptreact" },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = true,
                },
                per_filetype = {
                    ["html"] = { enable_close = true },
                    ["xml"] = { enable_close = true },
                    ["vue"] = { enable_close = true },
                },
            })
        end,
    },

    -- Linting
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                vue = { "eslint_d" },
            }

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd("BufWritePost", {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })

            vim.keymap.set("n", "<leader>l", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })
        end,
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            {
                "<leader>=",
                function()
                    require("conform").format({ lsp_fallback = true, async = true, timeout_ms = 2000 })
                end,
                mode = { "n", "v" },
                desc = "Format file or range",
            },
        },
        opts = {
            formatters_by_ft = {
                javascript = { "prettierd", "eslint_d" },
                typescript = { "prettierd", "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                vue = { "prettierd", "eslint_d" },
                svelte = { "prettierd" },
                css = { "prettierd" },
                html = { "prettierd" },
                json = { "prettierd" },
                yaml = { "prettierd" },
                graphql = { "prettierd" },
                lua = { "stylua" },
                dart = { "dart_format" },
                rust = { "rustfmt" },
                gdscript = { "gdformat" },
                toml = { "taplo" },
                markdown = { "mdformat" },
                blade = { "blade-formatter" },
            },
        },
    },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },

    -- Surround
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },

    -- Move lines/blocks
    {
        "booperlv/nvim-gomove",
        event = "VeryLazy",
        config = function()
            require("gomove").setup({
                map_defaults = false,
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

            -- Normal mode duplicate
            vim.keymap.set("n", "<leader>mh", "<Plug>GoNSDLeft", opts)
            vim.keymap.set("n", "<leader>mj", "<Plug>GoNSDDown", opts)
            vim.keymap.set("n", "<leader>mk", "<Plug>GoNSDUp", opts)
            vim.keymap.set("n", "<leader>ml", "<Plug>GoNSDRight", opts)

            -- Visual mode duplicate
            vim.keymap.set("x", "<leader>mh", "<Plug>GoVSDLeft", opts)
            vim.keymap.set("x", "<leader>mj", "<Plug>GoVSDDown", opts)
            vim.keymap.set("x", "<leader>mk", "<Plug>GoVSDUp", opts)
            vim.keymap.set("x", "<leader>ml", "<Plug>GoVSDRight", opts)
        end,
    },

    -- Yank history
    {
        "gbprod/yanky.nvim",
        event = "VeryLazy",
        config = function()
            require("yanky").setup({
                ring = {
                    history_length = 100,
                    storage = "shada",
                    sync_with_numbered_registers = true,
                    ignore_registers = { "_" },
                    update_register_on_cycle = false,
                    permanent_wrapper = nil,
                },
                system_clipboard = {
                    sync_with_ring = true,
                    clipboard_register = nil,
                },
                highlight = {
                    on_put = false,
                    on_yank = false,
                    timer = 500,
                },
                preserve_cursor_position = {
                    enabled = true,
                },
            })

            vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
            vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
            vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
            vim.keymap.set("n", "]p", "<Plug>(YankyCycleForward)")
            vim.keymap.set("n", "[p", "<Plug>(YankyCycleBackward)")
            vim.keymap.set({ "n" }, "<leader>pp", "<cmd>YankyRingHistory<cr>")
        end,
    },

    -- Search and replace
    {
        "nvim-pack/nvim-spectre",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            {
                "<leader>S",
                function()
                    require("spectre").toggle()
                end,
                desc = "Toggle Spectre",
            },
            {
                "<leader>sw",
                function()
                    require("spectre").open_visual({ select_word = true })
                end,
                desc = "Search current word",
            },
            {
                "<leader>sw",
                function()
                    require("spectre").open_visual()
                end,
                mode = "v",
                desc = "Search current word",
            },
            {
                "<leader>sp",
                function()
                    require("spectre").open_file_search({ select_word = true })
                end,
                desc = "Search on current file",
            },
        },
    },

    -- Comment
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
