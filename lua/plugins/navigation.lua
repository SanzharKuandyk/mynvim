return {
    -- Harpoon
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            {
                "<leader>hm",
                function()
                    require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
                end,
                desc = "Harpoon menu",
            },
            {
                "<leader>ja",
                function()
                    require("harpoon"):list():add()
                end,
                desc = "Harpoon add",
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
                "<leader>hf",
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
        config = function()
            local gitignore_cache = {} ---@type table<string, table<string, boolean>>

            local function is_gitignored(name, dir)
                if not gitignore_cache[dir] then
                    local out = vim.fn.systemlist({
                        "git",
                        "-C",
                        dir,
                        "ls-files",
                        "--others",
                        "--ignored",
                        "--exclude-standard",
                        "--directory",
                    })
                    local set = {}
                    for _, f in ipairs(out) do
                        set[f:gsub("/$", "")] = true
                    end
                    gitignore_cache[dir] = set
                end
                return gitignore_cache[dir][name] == true
            end

            require("oil").setup({
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
                view_options = {
                    is_hidden_file = function(name, bufnr)
                        if name:match("^%.") or vim.endswith(name, ".gd.uid") then
                            return true
                        end
                        local dir = require("oil").get_current_dir(bufnr)
                        if not dir then
                            return false
                        end
                        return is_gitignored(name, dir)
                    end,
                },
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "OilActionsPost",
                callback = function(ev)
                    for _, action in ipairs(ev.data.actions) do
                        if action.type == "delete" then
                            local path = action.url:gsub("^oil://", "")
                            local bufnr = vim.fn.bufnr(path)
                            if bufnr ~= -1 then
                                vim.api.nvim_buf_delete(bufnr, { force = true })
                            end
                        end
                    end
                end,
            })

            vim.keymap.set(
                { "n", "v" },
                "<leader>-",
                "<cmd>Oil<CR>",
                { desc = "Oil parent directory", noremap = true, silent = true }
            )
        end,
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
