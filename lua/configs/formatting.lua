local conform = require("conform")

conform.setup({
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
})

-- Map a key combination to format using Conform (optional)
vim.keymap.set({ "n", "v" }, "<leader>=", function()
    conform.format({ lsp_fallback = true, async = true, timeout_ms = 2000 })
end, { desc = "Format file or range (in visual mode)" })
