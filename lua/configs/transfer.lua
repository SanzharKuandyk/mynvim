vim.keymap.set("n", "<leader>tu", ":lua Upload_current_file()<CR>", { silent = true })

function Upload_current_file()
    local file_path = vim.fn.expand("%:p")
    if file_path == "" then
        vim.notify("No file in current buffer", "error", { title = "Transfer" })
        return
    end

    local relative_path = vim.fn.fnamemodify(file_path, ":.")
    relative_path = relative_path:gsub("\\", "/") -- normalize for Windows

    vim.cmd("TransferUpload " .. vim.fn.fnameescape(relative_path))
end
