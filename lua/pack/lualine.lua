-- lualine.nvim (migrated from lazy.nvim to vim.pack).
-- Setup moved here from init.lua. The "grapple" component needs grapple loaded;
-- grapple's pack file loads earlier (alphabetical order in the loader).
vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-lualine/lualine.nvim",
})

require("lualine").setup({
	sections = {
		lualine_b = { "grapple" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "filetype" },
		lualine_y = { "branch", "diff" },
	},
})
