return {
    -- Harpoon
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            {
                "<leader>ja",
                function()
                    require("harpoon"):list():add()
                end,
                desc = "Harpoon add",
            },
            {
                "<leader>jm",
                function()
                    require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
                end,
                desc = "Harpoon menu",
            },
            {
                "<leader>j1",
                function()
                    require("harpoon"):list():select(1)
                end,
                desc = "Harpoon 1",
            },
            {
                "<leader>j2",
                function()
                    require("harpoon"):list():select(2)
                end,
                desc = "Harpoon 2",
            },
            {
                "<leader>j3",
                function()
                    require("harpoon"):list():select(3)
                end,
                desc = "Harpoon 3",
            },
            {
                "<leader>j4",
                function()
                    require("harpoon"):list():select(4)
                end,
                desc = "Harpoon 4",
            },
            {
                "<leader>jp",
                function()
                    require("harpoon"):list():prev()
                end,
                desc = "Harpoon prev",
            },
            {
                "<leader>jn",
                function()
                    require("harpoon"):list():next()
                end,
                desc = "Harpoon next",
            },
            {
                "<leader>hv",
                function()
                    local harpoon = require("harpoon")
                    local conf = require("telescope.config").values
                    local file_paths = {}
                    for _, item in ipairs(harpoon:list().items) do
                        table.insert(file_paths, item.value)
                    end
                    require("telescope.pickers")
                        .new({}, {
                            prompt_title = "Harpoon",
                            finder = require("telescope.finders").new_table({ results = file_paths }),
                            previewer = conf.file_previewer({}),
                            sorter = conf.generic_sorter({}),
                        })
                        :find()
                end,
                desc = "Harpoon telescope",
            },
        },
        config = function()
            require("harpoon"):setup({})
        end,
    },

    -- Harpoon lualine integration
    {
        "letieu/harpoon-lualine",
        dependencies = { "ThePrimeagen/harpoon" },
    },

    -- File browser
    {
        "stevearc/oil.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<C-b>", "<cmd>Oil<CR>", desc = "Oil file browser", mode = "n", noremap = true, silent = true },
            {
                "<leader>-",
                ":<C-U>Oil<CR>",
                desc = "Oil parent directory",
                mode = { "n", "v" },
                noremap = true,
                silent = true,
            },
        },
        opts = {
            keymaps = {
                ["g?"] = { "actions.show_help", mode = "n" },
                ["<CR>"] = "actions.select",
                ["."] = "actions.select",
                ["dv"] = { "actions.select", opts = { vertical = true } },
                ["dh"] = { "actions.select", opts = { horizontal = true } },
                ["<C-t>"] = { "actions.select", opts = { tab = true } },
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = { "actions.close", mode = "n" },
                ["<C-n>"] = "actions.refresh",
                ["-"] = { "actions.parent", mode = "n" },
                ["_"] = { "actions.open_cwd", mode = "n" },
                ["`"] = { "actions.cd", mode = "n" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gx"] = "actions.open_external",
                ["g."] = { "actions.toggle_hidden", mode = "n" },
                ["g\\"] = { "actions.toggle_trash", mode = "n" },
            },
            use_default_keymaps = false,
        },
    },

    -- Better marks
    {
        "chentoast/marks.nvim",
        event = "BufReadPost",
        opts = {
            default_mappings = true,
            cyclic = true,
            force_write_shada = false,
            refresh_interval = 250,
            sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
            excluded_filetypes = {},
            excluded_buftypes = {},
            bookmark_0 = {
                sign = "⚑",
                virt_text = "hello world",
                annotate = false,
            },
            mappings = {},
        },
    },

    -- Move on line by unique letters
    {
        "jinh0/eyeliner.nvim",
        keys = { "f", "F", "t", "T" },
        opts = {},
    },

    -- Goto preview
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        keys = {
            { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview definition" },
            { "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "Preview type def" },
            {
                "gpi",
                "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
                desc = "Preview implementation",
            },
            { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "Preview references" },
            { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close all previews" },
        },
        config = function()
            require("goto-preview").setup({
                width = 120,
                height = 15,
                border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" },
                default_mappings = true,
                debug = false,
                opacity = nil,
                resizing_mappings = false,
                post_open_hook = nil,
                post_close_hook = nil,
                references = {
                    provider = "telescope",
                    telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
                },
                focus_on_open = true,
                dismiss_on_move = false,
                force_close = true,
                bufhidden = "wipe",
                stack_floating_preview_windows = true,
                same_file_float_preview = true,
                preview_window_title = { enable = true, position = "left" },
                zindex = 1,
                vim_ui_input = true,
            })
        end,
    },
}
