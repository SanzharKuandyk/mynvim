return {
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		event = { "InsertEnter", "CmdlineEnter" },
		version = "*",
		opts = {
			keymap = { preset = "default" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
			signature = { enabled = true },
			completion = {
				keyword = { range = "full" },
				trigger = {
					prefetch_on_insert = true,
					show_on_keyword = true,
				},
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind", gap = 2 },
						},
					},
				},
				ghost_text = { enabled = true },
			},
			cmdline = {
				completion = { menu = { auto_show = true } },
			},
		},
		opts_extend = { "sources.default" },
	},
}
