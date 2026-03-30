-- Disable auto-comments on newlines
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

-- OSC 7 for terminal directory tracking
vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        local cwd = vim.fn.getcwd():gsub("\\", "/")
        vim.api.nvim_ui_send("\027]7;file://localhost/" .. cwd .. "\027\\")
    end,
})
