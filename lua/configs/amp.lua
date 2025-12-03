-- Send a quick message to the agent
vim.api.nvim_create_user_command("AmpSend", function(opts)
    local message = opts.args
    if message == "" then
        print("Please provide a message to send")
        return
    end

    local amp_message = require("amp.message")
    amp_message.send_message(message)
end, {
    nargs = "*",
    desc = "Send a message to Amp",
})

-- Send entire buffer contents
vim.api.nvim_create_user_command("AmpSendBuffer", function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")

    local amp_message = require("amp.message")
    amp_message.send_message(content)
end, {
    nargs = "?",
    desc = "Send current buffer contents to Amp",
})

-- Add selected text directly to prompt
vim.api.nvim_create_user_command("AmpPromptSelection", function(opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    local text = table.concat(lines, "\n")

    local amp_message = require("amp.message")
    amp_message.send_to_prompt(text)
end, {
    range = true,
    desc = "Add selected text to Amp prompt",
})

-- Add file+selection reference to prompt
vim.api.nvim_create_user_command("AmpPromptRef", function(opts)
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == "" then
        print("Current buffer has no filename")
        return
    end

    local relative_path = vim.fn.fnamemodify(bufname, ":.")
    local ref = "@" .. relative_path
    if opts.line1 ~= opts.line2 then
        ref = ref .. "#L" .. opts.line1 .. "-" .. opts.line2
    elseif opts.line1 > 1 then
        ref = ref .. "#L" .. opts.line1
    end

    local amp_message = require("amp.message")
    amp_message.send_to_prompt(ref)
end, {
    range = true,
    desc = "Add file reference (with selection) to Amp prompt",
})

local map = vim.keymap.set

-- AmpSend (command mode takes args, so no visual version)
map("n", "<leader>as", ":AmpSend ", { desc = "Amp: send message" })

-- AmpSendBuffer
map("n", "<leader>ab", "<cmd>AmpSendBuffer<CR>", { desc = "Amp: send buffer" })

-- AmpPromptSelection (works in visual mode)
map("v", "<leader>ap", ":AmpPromptSelection<CR>", { desc = "Amp: add selection to prompt" })

-- AmpPromptRef (works in visual mode)
map("v", "<leader>ar", ":AmpPromptRef<CR>", { desc = "Amp: add file/selection ref to prompt" })
