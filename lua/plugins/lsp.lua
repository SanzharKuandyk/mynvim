return {
    -- Properly configures LuaLs for editing nvim config
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- Mason: LSP installer
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = {},
    },

    -- Mason LSP config bridge
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            ensure_installed = { "clangd", "vue_ls", "lua_ls" },
            automatic_installation = false,
            automatic_enable = false,
        },
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lsp = vim.lsp
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- Helper: check if executable exists
            local function is_executable(cmd)
                return vim.fn.executable(cmd) == 1
            end

            -- Collect enabled servers dynamically
            local enabled_servers = {}

            -- clangd
            if is_executable("clangd") then
                lsp.config("clangd", {
                    cmd = { "clangd", "--background-index" },
                    filetypes = { "c", "cpp", "objc", "objcpp" },
                    root_dir = vim.fs.root(0, { "compile_commands.json", "compile_flags.txt", ".git" }),
                    capabilities = capabilities,
                })
                table.insert(enabled_servers, "clangd")
            end

            local function is_port_open(host, port)
                local tcp = vim.uv.new_tcp()
                if not tcp then
                    return false
                end
                local connected = false
                tcp:connect(host, port, function(err)
                    connected = not err
                end)
                vim.uv.run("nowait")
                tcp:close()
                return connected
            end

            -- gdscript (TCP connection, check if Godot LSP is running)
            if is_port_open("127.0.0.1", 6005) then
                lsp.config("gdscript", {
                    cmd = lsp.rpc.connect("127.0.0.1", 6005),
                    root_dir = vim.fs.root(0, { "project.godot", ".git" }),
                    filetypes = { "gd", "gdscript", "gdscript3" },
                    capabilities = capabilities,
                })
                table.insert(enabled_servers, "gdscript")
            end

            -- dartls
            if is_executable("dart") then
                lsp.config("dartls", {
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
                    capabilities = capabilities,
                })
                table.insert(enabled_servers, "dartls")
            end

            -- vue_ls (only for projects with tsconfig)
            local vue_root = vim.fs.root(0, { "tsconfig.json" })
            if is_executable("vue-language-server") and vue_root then
                lsp.config("vue_ls", {
                    init_options = {
                        vue = {
                            hybridMode = false,
                        },
                    },
                    capabilities = capabilities,
                })
                table.insert(enabled_servers, "vue_ls")
            end

            -- lua_ls
            if is_executable("lua-language-server") then
                lsp.config("lua_ls", {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim", "uv" },
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                        },
                    },
                    capabilities = capabilities,
                })
                table.insert(enabled_servers, "lua_ls")
            end

            -- Enable only servers that exist
            if #enabled_servers > 0 then
                lsp.enable(enabled_servers)
            end

            -- Keybindings for LSP
            local buf_map = function(bufnr, mode, lhs, rhs, opts)
                vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts or { silent = true })
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    if client and client.server_capabilities and client.server_capabilities.semanticTokensProvider then
                        client.server_capabilities.semanticTokensProvider = nil
                    end

                    local bufnr = ev.buf
                    buf_map(bufnr, "n", "gd", "<cmd>Trouble lsp_definitions<CR>")
                    buf_map(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
                    buf_map(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
                    buf_map(bufnr, "n", "S", "<cmd>lua vim.lsp.buf.hover()<CR>")
                    buf_map(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
                    buf_map(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
                    buf_map(bufnr, "n", "<leader>sh", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
                    buf_map(bufnr, "n", "<leader>of", "<cmd>lua vim.diagnostic.open_float()<CR>")
                    buf_map(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
                    buf_map(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
                    buf_map(
                        bufnr,
                        "n",
                        "[e",
                        "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>"
                    )
                    buf_map(
                        bufnr,
                        "n",
                        "]e",
                        "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>"
                    )
                    buf_map(
                        bufnr,
                        "n",
                        "[w",
                        "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<CR>"
                    )
                    buf_map(
                        bufnr,
                        "n",
                        "]w",
                        "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<CR>"
                    )
                end,
            })
        end,
    },

    -- Lsp progress ui
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {
            -- options
        },
    },

    -- Rust tools
    {
        "mrcjkb/rustaceanvim",
        version = "^7",
        ft = { "rust" },
        config = function()
            vim.g.rustaceanvim = {
                tools = {},
                server = {
                    on_attach = function(client, bufnr)
                        -- Rust-specific code action (grouped UI, better for imports)
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
                            completion = {
                                autoimport = { enable = true },
                            },
                        },
                    },
                },
                dap = {},
            }
        end,
    },

    -- TypeScript tools
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        opts = {
            on_attach = function(client)
                client.server_capabilities.semanticTokensProvider = nil
            end,
            handlers = {},
            filetypes = {
                "javascriptreact",
                "javascript.jsx",
                "typescriptreact",
                "typescript.tsx",
            },
            settings = {
                separate_diagnostic_server = true,
                expose_as_code_action = {},
                tsserver_plugins = {
                    "@styled/typescript-styled-plugin",
                    "@vue/language-server",
                    "@vue/typescript-plugin",
                },
                tsserver_max_memory = 2024,
                tsserver_format_options = {},
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

    -- DAP (Debug Adapter Protocol)
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
            dap.adapters.godot = {
                type = "server",
                host = "127.0.0.1",
                port = 6006,
            }

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
                local env_utils = require("utils.env")
                local env = env_utils.Load_env() or {}
                return env["GODOT_ADDRESS"] or "127.0.0.1:55432"
            end

            local function is_address_in_use(address)
                local ip, port = address:match("(.+):(%d+)")
                local command = vim.fn.has("win32") == 1 and ("netstat -ano | findstr :" .. port)
                    or ("ss -tuln | grep " .. ip .. ":" .. port)
                local result = vim.fn.system(command)
                return result ~= ""
            end

            local godot_connected = false

            local function start_godot_connection(address)
                if godot_connected then
                    return
                end
                local godot_project_file = vim.fn.getcwd() .. "/project.godot"
                local gdproject = io.open(godot_project_file, "r")
                if not gdproject then
                    return
                end
                io.close(gdproject)
                local godot_address = address or get_godot_address()
                if is_address_in_use(godot_address) then
                    print("Address " .. godot_address .. " is already in use. Aborting connection.")
                    return
                end
                vim.fn.serverstart(godot_address)
                godot_connected = true
                print("Godot connection started at " .. godot_address)
            end

            local function stop_godot_connection()
                local godot_address = get_godot_address()
                vim.fn.serverstop(godot_address)
                for _, client in pairs(vim.lsp.get_clients({ name = "gdscript" })) do
                    vim.lsp.stop_client(client.id)
                end
                godot_connected = false
                print("Godot connection and LSP stopped at " .. godot_address)
            end

            vim.api.nvim_create_user_command("StartGodotConnection", function(opts)
                local address = opts.args ~= "" and opts.args or nil
                start_godot_connection(address)
            end, { nargs = "?" })

            vim.api.nvim_create_user_command("StopGodotConnection", stop_godot_connection, {})

            vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
                callback = function()
                    if not godot_connected then
                        start_godot_connection()
                    end
                end,
            })

            vim.api.nvim_create_autocmd("BufReadPost", {
                pattern = "*.gd",
                callback = function()
                    local clients = vim.lsp.get_clients({ name = "gdscript" })
                    if
                        #clients == 0
                        or vim.tbl_contains(clients, function(c)
                            return c.is_stopped()
                        end, { predicate = true })
                    then
                        print("GDScript LSP not running or stopped, starting connection...")
                        start_godot_connection()
                    end
                end,
            })

            vim.api.nvim_create_autocmd("VimLeave", {
                callback = function()
                    if godot_connected then
                        stop_godot_connection()
                    end
                end,
            })
        end,
    },

    -- Trouble: diagnostics viewer
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            { "<leader>xL", "<cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix List (Trouble)" },
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
            -- Disable virtual text by default
            vim.diagnostic.config({ virtual_text = false })
            require("tiny-inline-diagnostic").setup()
        end,
    },

    -- Symbols
    {
        "oskarrrrrrr/symbols.nvim",
        config = function()
            local r = require("symbols.recipes")
            require("symbols").setup(r.DefaultFilters, r.AsciiSymbols, {
                sidebar = {
                    -- custom settings here
                    hide_cursor = false,
                },
            })
            vim.keymap.set("n", ",s", "<cmd>Symbols<CR>")
            vim.keymap.set("n", ",S", "<cmd>SymbolsClose<CR>")
        end,
    },
}
