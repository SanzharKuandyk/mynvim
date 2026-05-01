-- Disable auto-comments on newlines
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

-- Fold Rust test modules by default
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*.rs",
    callback = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for i, line in ipairs(lines) do
            if line:match("#%[cfg%(test%)%]") or line:match("^mod tests") then
                pcall(vim.cmd, i .. "foldclose")
            end
        end
    end,
})

-- OSC 7 for terminal directory tracking
vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        local cwd = vim.fn.getcwd():gsub("\\", "/")
        vim.api.nvim_ui_send("\027]7;file://localhost/" .. cwd .. "\027\\")
    end,
})
