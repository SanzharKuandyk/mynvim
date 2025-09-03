-- Upload
vim.keymap.set("n", "<leader>uu", ":lua Upload_current_file()<CR>", { silent = true })

function Upload_current_file()
    local file_path = vim.fn.expand("%:p")
    if file_path == "" then
        vim.notify("No file in current buffer", vim.log.levels.ERROR, { title = "Transfer" })
        return
    end

    local relative_path = vim.fn.fnamemodify(file_path, ":.")
    relative_path = relative_path:gsub("\\", "/")

    vim.cmd("TransferUpload " .. vim.fn.fnameescape(relative_path))
end

-- Download
vim.keymap.set("n", "<leader>ud", ":lua Download_current_file()<CR>", { silent = true })

function Download_current_file()
    local file_path = vim.fn.expand("%:p")
    if file_path == "" then
        vim.notify("No file in current buffer", vim.log.levels.ERROR, { title = "Transfer" })
        return
    end

    local relative_path = vim.fn.fnamemodify(file_path, ":.")
    relative_path = relative_path:gsub("\\", "/")

    vim.cmd("TransferDownload " .. vim.fn.fnameescape(relative_path))
end
