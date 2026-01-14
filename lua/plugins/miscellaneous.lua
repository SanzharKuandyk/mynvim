return {
    {
        "SanzharKuandyk/incline-anki.nvim",
        dependencies = {
            "b0o/incline.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local env_utils = require("utils.env")
            local env = env_utils.Load_env() or {}
            require("incline-anki").setup({
                deck = env["ANKI_DECK"] or "Default",
                preset = "statusline",
                rotation_interval = 30000,
                fields_to_show = { "Sentence", "Expression" },
            })
        end,
    },
}
