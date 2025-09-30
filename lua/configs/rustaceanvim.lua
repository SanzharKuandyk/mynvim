vim.g.rustaceanvim = {
    -- Plugin configuration
    tools = {},
    -- LSP configuration
    server = {
        on_attach = function(client, bufnr)
            if vim.lsp.buf.inlay_hint then
                vim.lsp.buf.inlay_hint(bufnr, true)
            end
        end,
        default_settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {
                imports = { granularity = { group = "module" }, prefix = "self" },
                cargo = { buildScripts = { enable = true } },
                procMacro = { enable = true },
                diagnostics = { experimental = { enable = true } },
            },
        },
    },
    -- DAP configuration
    dap = {},
}
