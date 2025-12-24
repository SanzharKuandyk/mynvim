return {
	-- Transfer.nvim for remote file sync via SFTP/rsync
	{
		"coffebar/transfer.nvim",
		cmd = {
			"TransferInit",
			"DiffRemote",
			"TransferUpload",
			"TransferDownload",
			"TransferDirDiff",
			"TransferRepeat",
		},
		keys = {
			{
				"<leader>uu",
				function()
					local file_path = vim.fn.expand("%:p")
					if file_path == "" then
						vim.notify("No file in current buffer", vim.log.levels.ERROR, { title = "Transfer" })
						return
					end
					local relative_path = vim.fn.fnamemodify(file_path, ":.")
					relative_path = relative_path:gsub("\\", "/")
					vim.cmd("TransferUpload " .. vim.fn.fnameescape(relative_path))
				end,
				desc = "Upload current file",
			},
			{
				"<leader>ud",
				function()
					local file_path = vim.fn.expand("%:p")
					if file_path == "" then
						vim.notify("No file in current buffer", vim.log.levels.ERROR, { title = "Transfer" })
						return
					end
					local relative_path = vim.fn.fnamemodify(file_path, ":.")
					relative_path = relative_path:gsub("\\", "/")
					vim.cmd("TransferDownload " .. vim.fn.fnameescape(relative_path))
				end,
				desc = "Download current file",
			},
		},
		opts = {},
	},
}
