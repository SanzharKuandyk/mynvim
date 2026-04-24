local specs = {
    -- Lua LSP for Neovim config
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- LSP installer
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = {},
    },

    -- Mason <-> lspconfig bridge
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            ensure_installed = { "clangd", "lua_ls" },
            automatic_installation = false,
            automatic_enable = false,
        },
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim", "saghen/blink.cmp" },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lsp = vim.lsp
            local caps = require("blink.cmp").get_lsp_capabilities()

            vim.diagnostic.config({
                float = {
                    border = "rounded",
                    padding = { 1, 1, 1, 1 },
                },
            })

            -- Helper to check if exe exists
            local function exe(cmd)
                return vim.fn.executable(cmd) == 1
            end

            -- Register a server if condition is met
            local enabled = {}
            ---@param cond boolean
            ---@param name string
            ---@param config vim.lsp.Config
            local function server(cond, name, config)
                if not cond then
                    return
                end
                lsp.config(name, config)
                enabled[#enabled + 1] = name
            end

            -- Lua
            ---@type vim.lsp.Config
            local lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim", "uv" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                    },
                },
                capabilities = caps,
            }
            server(exe("lua-language-server"), "lua_ls", lua_ls)

            ---@type vim.lsp.Config
            local clangd = {
                cmd = { "clangd", "--background-index" },
                filetypes = { "c", "cpp", "objc", "objcpp" },
                root_dir = vim.fs.root(0, { "compile_commands.json", "compile_flags.txt", ".git" }),
                capabilities = caps,
            }
            server(exe("clangd"), "clangd", clangd)

            -- Zig
            ---@type vim.lsp.Config
            local zls = {
                cmd = { "zls" },
                filetypes = { "zig" },
                root_dir = vim.fs.root(0, { "build.zig", ".git" }),
                capabilities = caps,
            }
            server(exe("zls"), "zls", zls)

            -- Odin
            ---@type vim.lsp.Config
            local ols = {
                init_options = {
                    checker_args = "-strict-style",
                    collections = { { name = "shared", path = vim.fn.expand("$HOME/odin-lib") } },
                },
                capabilities = caps,
            }
            server(exe("ols"), "ols", ols)

            ---@type vim.lsp.Config
            local dartls = {
                settings = {
                    dart = {
                        analysisExcludedFolders = {
                            vim.fn.expand("$HOME/.pub-cache"),
                            vim.fn.expand("$HOME/flutter"),
                        },
                        updateImportsOnRename = true,
                        completeFunctionCalls = true,
                    },
                },
                capabilities = caps,
            }
            server(exe("dart"), "dartls", dartls)

            ---@type vim.lsp.Config
            local vue_ls = {
                init_options = { vue = { hybridMode = false } },
                capabilities = caps,
            }
            server(exe("vue-language-server") and vim.fs.root(0, { "tsconfig.json" }) ~= nil, "vue_ls", vue_ls)

            if #enabled > 0 then
                lsp.enable(enabled)
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    if vim.g.lsp_disabled then
                        vim.lsp.stop_client(ev.data.client_id)
                        return
                    end
                    local client = lsp.get_client_by_id(ev.data.client_id)
                    local bufnr = ev.buf

                    -- Prefer treesitter highlighting over semantic tokens
                    if client and client.server_capabilities.semanticTokensProvider then
                        client.server_capabilities.semanticTokensProvider = nil
                    end

                    -- Inlay hints
                    if client and client:supports_method("textDocument/inlayHint", bufnr) then
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end

                    local map = function(lhs, rhs)
                        vim.keymap.set("n", lhs, rhs, { silent = true, buffer = bufnr })
                    end

                    map("gd", "<cmd>Trouble lsp_definitions<CR>")
                    map("gr", vim.lsp.buf.references)
                    map("gi", vim.lsp.buf.implementation)
                    map("S", vim.lsp.buf.hover)
                    map("<leader>rn", vim.lsp.buf.rename)
                    map("<leader>ca", vim.lsp.buf.code_action)
                    map("<leader>sh", function()
                        vim.schedule(vim.lsp.buf.signature_help)
                    end)
                    map("<leader>of", vim.diagnostic.open_float)
                    map("[d", function()
                        vim.diagnostic.jump({ count = -1 })
                    end)
                    map("]d", function()
                        vim.diagnostic.jump({ count = 1 })
                    end)
                    map("[e", function()
                        vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
                    end)
                    map("]e", function()
                        vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
                    end)
                    map("[w", function()
                        vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
                    end)
                    map("]w", function()
                        vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
                    end)
                end,
            })
        end,
    },

    -- LSP progress UI
    { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

    -- LSP garbage collector
    { "zeioth/garbage-day.nvim", event = "VeryLazy", opts = {} },

    -- Rust
    {
        "mrcjkb/rustaceanvim",
        version = "^9",
        lazy = false,
        config = function()
            vim.g.rustaceanvim = {
                tools = {},
                server = {
                    on_attach = function(client, bufnr)
                        if vim.g.lsp_disabled then
                            vim.lsp.stop_client(client.id)
                            return
                        end
                        vim.keymap.set("n", "<leader>ca", function()
                            vim.cmd.RustLsp("codeAction")
                        end, { silent = true, buffer = bufnr, desc = "Rust code action" })
                    end,
                    default_settings = {
                        ["rust-analyzer"] = {
                            imports = {
                                granularity = { group = "module" },
                                prefix = "plain",
                            },
                            completion = { autoimport = { enable = true } },
                        },
                    },
                },
            }
        end,
    },

    -- Diagnostics viewer
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<CR>",
                desc = "Diagnostics (Trouble)",
            },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
            { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP (Trouble)" },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<CR>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<CR>",
                desc = "Quickfix List (Trouble)",
            },
        },
        opts = {
            auto_refresh = true,
            follow = true,
        },
    },

    -- Inline diagnostics
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach",
        config = function()
            vim.diagnostic.config({ virtual_text = false })
            require("tiny-inline-diagnostic").setup()
        end,
    },

    -- Symbol sidebar
    {
        "oskarrrrrrr/symbols.nvim",
        config = function()
            local r = require("symbols.recipes")
            require("symbols").setup(r.DefaultFilters, r.AsciiSymbols, {
                sidebar = { hide_cursor = false },
            })
            vim.keymap.set("n", ",s", "<cmd>Symbols<CR>")
            vim.keymap.set("n", ",S", "<cmd>SymbolsClose<CR>")
        end,
    },
}

vim.list_extend(specs, require("plugins.lsp.godot"))

return specs
