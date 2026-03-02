return {
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

            -- Helper to check if port is open
            local function port_open(host, port)
                local tcp = vim.uv.new_tcp()
                if not tcp then
                    return false
                end
                local ok = false
                tcp:connect(host, port, function(err)
                    ok = not err
                end)
                vim.uv.run("nowait")
                tcp:close()
                return ok
            end

            -- Register a server if condition is met
            local enabled = {}
            local function server(cond, name, config)
                if not cond then
                    return
                end
                lsp.config(name, config)
                enabled[#enabled + 1] = name
            end

            -- Lua
            server(exe("lua-language-server"), "lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim", "uv" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                    },
                },
                capabilities = caps,
            })

            server(exe("clangd"), "clangd", {
                cmd = { "clangd", "--background-index" },
                filetypes = { "c", "cpp", "objc", "objcpp" },
                root_dir = vim.fs.root(0, { "compile_commands.json", "compile_flags.txt", ".git" }),
                capabilities = caps,
            })

            -- Zig
            server(exe("zls"), "zls", {
                cmd = { "zls" },
                filetypes = { "zig" },
                root_dir = vim.fs.root(0, { "build.zig", ".git" }),
                capabilities = caps,
            })

            -- Odin
            server(exe("ols"), "ols", {
                init_options = {
                    checker_args = "-strict-style",
                    collections = { { name = "shared", path = vim.fn.expand("$HOME/odin-lib") } },
                },
                capabilities = caps,
            })

            -- Godot's gdscript
            server(port_open("127.0.0.1", 6005), "gdscript", {
                cmd = lsp.rpc.connect("127.0.0.1", 6005),
                root_dir = vim.fs.root(0, { "project.godot", ".git" }),
                filetypes = { "gd", "gdscript", "gdscript3" },
                capabilities = caps,
            })

            server(exe("dart"), "dartls", {
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
            })

            server(exe("vue-language-server") and vim.fs.root(0, { "tsconfig.json" }) ~= nil, "vue_ls", {
                init_options = { vue = { hybridMode = false } },
                capabilities = caps,
            })

            if #enabled > 0 then
                lsp.enable(enabled)
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local client = lsp.get_client_by_id(ev.data.client_id)
                    local bufnr = ev.buf

                    -- Prefer treesitter highlighting over semantic tokens
                    if client and client.server_capabilities.semanticTokensProvider then
                        client.server_capabilities.semanticTokensProvider = nil
                    end

                    -- Inlay hints
                    if client and client.supports_method("textDocument/inlayHint") then
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
                    map("[d", vim.diagnostic.goto_prev)
                    map("]d", vim.diagnostic.goto_next)
                    map("[e", function()
                        vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
                    end)
                    map("]e", function()
                        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
                    end)
                    map("[w", function()
                        vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
                    end)
                    map("]w", function()
                        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
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
        version = "^7",
        config = function()
            vim.g.rustaceanvim = {
                tools = {},
                server = {
                    on_attach = function(_, bufnr)
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
                dap = {},
            }

            vim.api.nvim_create_autocmd("User", {
                pattern = "RustaceanvimLoaded",
                callback = function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.bo[buf].filetype == "rust" and vim.bo[buf].buflisted then
                            vim.cmd("LspStart rust_analyzer")
                        end
                    end
                end,
            })
        end,
    },

    -- TypeScript
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {
            on_attach = function(client)
                client.server_capabilities.semanticTokensProvider = nil
            end,
            filetypes = {
                "javascriptreact",
                "javascript.jsx",
                "typescript",
                "typescriptreact",
                "typescript.tsx",
            },
            settings = {
                separate_diagnostic_server = true,
                tsserver_plugins = {
                    "@styled/typescript-styled-plugin",
                    "@vue/language-server",
                    "@vue/typescript-plugin",
                },
                tsserver_max_memory = 2024,
                tsserver_file_preferences = {
                    includeInlayParameterNameHints = "all",
                },
                tsserver_locale = "en",
                complete_function_calls = false,
                include_completions_with_insert_text = false,
                code_lens = "off",
                disable_member_code_lens = true,
            },
        },
    },

    -- DAP
    {
        "mfussenegger/nvim-dap",
        dependencies = { "rcarriga/nvim-dap-ui" },
        keys = {
            { "<F5>", "<cmd>DapContinue<CR>", desc = "DAP Continue" },
            { "<F10>", "<cmd>DapStepOver<CR>", desc = "DAP Step Over" },
            { "<F11>", "<cmd>DapStepInto<CR>", desc = "DAP Step Into" },
            { "<F12>", "<cmd>DapStepOut<CR>", desc = "DAP Step Out" },
        },
        config = function()
            local dap = require("dap")
            dap.adapters.godot = { type = "server", host = "127.0.0.1", port = 6006 }
            dap.configurations.gdscript = {
                {
                    type = "godot",
                    request = "launch",
                    name = "Launch scene",
                    project = "${workspaceFolder}",
                    launch_scene = true,
                },
            }
        end,
    },

    -- Godot integration
    {
        "habamax/vim-godot",
        ft = { "gdscript", "gdshader" },
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "gdscript",
                callback = function()
                    vim.opt_local.expandtab = false
                    vim.opt_local.tabstop = 4
                    vim.opt_local.shiftwidth = 4
                    vim.opt_local.softtabstop = 4
                    vim.opt_local.indentexpr = ""
                end,
            })

            local function get_godot_address()
                local env = require("utils.env").Load_env() or {}
                return env["GODOT_ADDRESS"] or "127.0.0.1:55432"
            end

            local function is_address_in_use(address)
                local _, port = address:match("(.+):(%d+)")
                local cmd = vim.fn.has("win32") == 1 and ("netstat -ano | findstr :" .. port)
                    or ("ss -tuln | grep " .. address)
                return vim.fn.system(cmd) ~= ""
            end

            local godot_connected = false

            local function start_godot_connection(address)
                if godot_connected then
                    return
                end
                local f = io.open(vim.fn.getcwd() .. "/project.godot", "r")
                if not f then
                    return
                end
                io.close(f)
                local addr = address or get_godot_address()
                if is_address_in_use(addr) then
                    print("Address " .. addr .. " already in use")
                    return
                end
                vim.fn.serverstart(addr)
                godot_connected = true
                print("Godot connection started at " .. addr)
            end

            local function stop_godot_connection()
                local addr = get_godot_address()
                vim.fn.serverstop(addr)
                for _, client in pairs(vim.lsp.get_clients({ name = "gdscript" })) do
                    vim.lsp.stop_client(client.id)
                end
                godot_connected = false
                print("Godot connection stopped at " .. addr)
            end

            vim.api.nvim_create_user_command("StartGodotConnection", function(opts)
                start_godot_connection(opts.args ~= "" and opts.args or nil)
            end, { nargs = "?" })

            vim.api.nvim_create_user_command("StopGodotConnection", stop_godot_connection, {})

            vim.api.nvim_create_autocmd("VimLeave", {
                callback = function()
                    if godot_connected then
                        stop_godot_connection()
                    end
                end,
            })
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
