return {
	-- Nagisa theme (provides EndOfTheWorld colorscheme)
	{
		"sanzharkuandyk/nagisa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("nagisa").setup({})
			-- Set default colorscheme after plugin loads
			vim.cmd.colorscheme("EndOfTheWorld")
		end,
	},

	-- Midnight theme
	{
		"dasupradyumna/midnight.nvim",
		lazy = false,
		priority = 1000,
	},

	-- Theme switcher
	{
		"zaldih/themery.nvim",
		cmd = "Themery",
		opts = {
			themes = { "EndOfTheWorld", "midnight" },
			livePreview = true,
		},
	},
}
