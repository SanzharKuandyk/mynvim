-- Disable auto-comments on newlines
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

-- OSC 7 for terminal directory tracking
vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        local cwd = vim.fn.getcwd()
        local cwd_escaped = cwd:gsub("\\", "\\\\")
        vim.cmd('silent! call chansend(v:stderr, "\\033]7;file:///' .. cwd_escaped .. '\\007")')
    end,
})
