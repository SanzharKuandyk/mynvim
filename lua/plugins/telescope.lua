return {
    -- Telescope fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "nvim-telescope/telescope-project.nvim",
            "folke/trouble.nvim",
        },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<leader>lfg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep (literal)" },
            { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor (literal)" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
            {
                "<leader>fc",
                function()
                    local pickers = require("telescope.pickers")
                    local finders = require("telescope.finders")
                    local conf = require("telescope.config").values
                    local Path = require("plenary.path")

                    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
                    if not git_root or git_root == "" then
                        vim.notify("Not a git repository", vim.log.levels.WARN)
                        return
                    end

                    local results = vim.fn.systemlist("git status --porcelain=v1")

                    pickers
                        .new({}, {
                            prompt_title = "Git Status",
                            finder = finders.new_table({
                                results = results,
                                entry_maker = function(line)
                                    local status = line:sub(1, 2)
                                    local path = line:sub(4)

                                    local rel = Path:new(path):make_relative(git_root)

                                    return {
                                        value = path,
                                        ordinal = path,
                                        display = status .. " " .. rel,
                                        path = path,
                                        status = status,
                                    }
                                end,
                            }),
                            sorter = conf.generic_sorter({}),
                            previewer = conf.file_previewer({}),
                        })
                        :find()
                end,
                desc = "Git status (relative paths)",
            },
            { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Current buffer fuzzy find" },
            {
                "<leader>fp",
                function()
                    require("telescope").load_extension("project")
                    require("telescope").extensions.project.project()
                end,
                desc = "Projects",
            },
            {
                "<leader>fn",
                function()
                    require("telescope").extensions.notify.notify()
                end,
                desc = "Notifications",
            },
            {
                "<leader>tt",
                function()
                    require("search").open()
                end,
                desc = "Search tabs",
            },
        },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")
            local open_with_trouble = require("trouble.sources.telescope").open

            telescope.setup({
                defaults = {
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                        "--trim",
                        "--glob=!.git",
                        "-F",
                    },
                    file_ignore_patterns = {
                        "%.uid",

                        -- generic *.lock
                        "%.lock$",

                        -- JS / Node
                        "package%-lock%.json$",
                        "yarn%.lock$",
                        "pnpm%-lock%.yaml$",

                        -- Rust
                        "Cargo%.lock$",

                        -- Go
                        "go%.sum$",

                        -- Python
                        "Pipfile%.lock$",
                        "poetry%.lock$",
                    },
                    mappings = {
                        i = { ["<c-t>"] = open_with_trouble },
                        n = { ["<c-t>"] = open_with_trouble },
                    },
                    path_display = {
                        "filename_first",
                        {
                            truncate = 6, -- increase if your folders are deep
                        },
                    },
                },
                extensions = {
                    fzf = {},
                    project = {},
                },
            })

            require("search").setup({
                mappings = {
                    next = "<Tab>",
                    prev = "<S-Tab>",
                },
                append_tabs = {
                    {
                        "Commits",
                        builtin.git_commits,
                        available = function()
                            return vim.fn.isdirectory(".git") == 1
                        end,
                    },
                    {
                        "CBFF",
                        builtin.current_buffer_fuzzy_find,
                    },
                },
            })

            telescope.load_extension("fzf")
        end,
    },

    -- FZF native for telescope
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },

    -- Project management
    {
        "nvim-telescope/telescope-project.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },

    -- Search plugin with tabs
    {
        "FabianWirth/search.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
}
