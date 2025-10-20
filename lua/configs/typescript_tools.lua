require("typescript-tools").setup({
    on_attach = function(client)
        client.server_capabilities.semanticTokensProvider = nil
    end,
    handlers = {},
    filetypes = {
        "javascriptreact",
        "javascript.jsx",
        "typescriptreact",
        "typescript.tsx",
        "vue",
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
})
