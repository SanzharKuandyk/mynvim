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

-- Config navigation commands
local previous_directory = nil

local function open_config_folder()
	previous_directory = vim.fn.getcwd()
	local config_path = vim.fn.stdpath("config")
	vim.cmd("e " .. config_path)
end

local function return_to_previous_directory()
	if previous_directory then
		vim.cmd("e " .. previous_directory)
		previous_directory = nil
	else
		vim.notify("No previous directory saved!", vim.log.levels.WARN)
	end
end

vim.api.nvim_create_user_command("OpenConfig", open_config_folder, {})
vim.api.nvim_create_user_command("ReturnToPreviousDirectory", return_to_previous_directory, {})

vim.keymap.set("n", "<leader>oc", ":OpenConfig<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ob", ":ReturnToPreviousDirectory<CR>", { noremap = true, silent = true })
