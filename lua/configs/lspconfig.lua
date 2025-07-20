require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "clangd" },
    automatic_installation = false,
    automatic_enable = true,
})

local config = function(_, opts)
    local lspconfig = require("lspconfig")
    for server, config in pairs(opts.servers) do
        config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
    end
end

local opts = {
    servers = {
        clangd = {
            cmd = { "clangd", "--background-index" },
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_dir = require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
        },
        gdscript = {
            cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
            root_dir = require("lspconfig.util").root_pattern("project.godot", ".git"),
            filetypes = { "gd", "gdscript", "gdscript3" },
        },
        dartls = {
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
        },
        volar = {
            init_options = {
                vue = {
                    hybridMode = false,
                },
            },
        },
    },
}

config(nil, opts)

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
        buf_map(bufnr, "n", "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>")
        buf_map(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
        buf_map(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
        buf_map(bufnr, "n", "S", "<cmd>lua vim.lsp.buf.hover()<CR>")
        buf_map(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
        buf_map(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
        buf_map(bufnr, "n", "<leader>sh", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
        buf_map(bufnr, "n", "<leader>of", "<cmd>lua vim.diagnostic.open_float()<CR>")
        buf_map(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
        buf_map(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
    end,
})

vim.keymap.set("n", "<Tab>", ":EagleWin<CR>", { noremap = true, silent = true })
