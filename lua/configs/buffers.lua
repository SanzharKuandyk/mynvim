vim.keymap.set("n", "bl", ":lua require('buffer_manager.ui').toggle_quick_menu()<CR>", { silent = true })

function Delete_buffer()
    local bufnr = vim.fn.bufnr("%")
    if bufnr ~= -1 then
        vim.cmd(":Bdelete")
    else
        print("Invalid buffer number")
    end
end

function Wipeout_buffer()
    local bufnr = vim.fn.bufnr("%")
    if bufnr ~= -1 then
        vim.cmd(":Bwipeout")
    else
        print("Invalid buffer number")
    end
end

function Wipeout_all_buffers()
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end
end

vim.keymap.set("n", "<leader>bd", ":lua Delete_buffer()<CR>", { silent = true })
vim.keymap.set("n", "<leader>bw", ":lua Wipeout_buffer()<CR>", { silent = true })
vim.keymap.set("n", "bwa", ":lua Wipeout_all_buffers()<CR>", { silent = true })
