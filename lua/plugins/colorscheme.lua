return {
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme>
		priority = 1000,

		opts = {
			style = "night",
			styles = {
				comments = { italic = true },
				strings = {},
				keywords = {},
				functions = {},
				variables = {},
				operators = {},
				types = {},
			},
		},
	},
	{
		"marko-cerovac/material.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme>
		priority = 1000,
		opts = {
			styles = { -- Give comments style such as bold, italic, underline etc.
				comments = { italic = true },
				strings = { bold = true },
				keywords = {},
				functions = {},
				variables = {},
				operators = {},
				types = {},
			},
		},
	},
	{
		"Mofiqul/vscode.nvim",
		lazy = false,
		name = "vscode",
		opts = {
			styles = {
				comments = { italic = true },
				strings = {},
				keywords = {},
				functions = {},
				variables = {},
				operators = {},
				types = {},
			},
		},
	},
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000,
	},
}
