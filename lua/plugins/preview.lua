return {
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        dependencies = { "saghen/blink.cmp" },
        config = function()
            vim.keymap.set("n", "<leader>mv", "<cmd>Markview toggle<CR>", { desc = "Toggle markview preview" })
        end,
    },
}
