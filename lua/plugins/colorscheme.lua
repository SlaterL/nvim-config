return {
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme>
		priority = 1000,

		opts = {
			style = "night",
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
}
