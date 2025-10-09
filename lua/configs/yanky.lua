require("yanky").setup({
    ring = {
        history_length = 100,
        storage = "shada",
        sync_with_numbered_registers = true,
        ignore_registers = { "_" },
        update_register_on_cycle = false,
        permanent_wrapper = nil,
    },
    system_clipboard = {
        sync_with_ring = true,
        clipboard_register = nil,
    },
    highlight = {
        on_put = false,
        on_yank = false,
        timer = 500,
    },
    preserve_cursor_position = {
        enabled = true,
    },
})

vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set("n", "]p", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "[p", "<Plug>(YankyCycleBackward)")
vim.keymap.set({ "n" }, "<leader>pp", "<cmd>YankyRingHistory<cr>")
