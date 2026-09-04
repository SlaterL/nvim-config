-- Colorschemes (migrated from lazy.nvim to vim.pack).
-- Loaded eagerly from init.lua (before the :colorscheme command) since colors/
-- files only need to be on rtp — no deferred plugin/ sourcing required.
vim.pack.add({
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/marko-cerovac/material.nvim",
	"https://github.com/Mofiqul/vscode.nvim",
	"https://github.com/bluz71/vim-moonfly-colors",
})

require("tokyonight").setup({
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
})

require("material").setup({
	styles = {
		comments = { italic = true },
		strings = { bold = true },
		keywords = {},
		functions = {},
		variables = {},
		operators = {},
		types = {},
	},
})

require("vscode").setup({
	styles = {
		comments = { italic = true },
		strings = {},
		keywords = {},
		functions = {},
		variables = {},
		operators = {},
		types = {},
	},
})

-- moonfly is a vimscript colorscheme (bluz71/vim-moonfly-colors); no setup needed.
-- The actual `:colorscheme moonfly` call lives in init.lua.
