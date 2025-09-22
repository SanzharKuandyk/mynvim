require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "vue_ls" },
    automatic_installation = false,
    automatic_enable = true,
})

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

-- gdscript (TCP connection, so check port availability instead of executable)
local function is_port_open(host, port)
    local socket = vim.loop.new_tcp()
    local ok = socket:connect(host, port)
    socket:close()
    return ok
end

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

-- vue_ls
if is_executable("vue-language-server") then
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

-- Enable only servers that exist
if #enabled_servers > 0 then
    lsp.enable(enabled_servers)
end
