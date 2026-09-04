-- nvim-notify (migrated from lazy.nvim to vim.pack)
vim.pack.add({ "https://github.com/rcarriga/nvim-notify" })

require("notify").setup({
	timeout = 3000,
	max_height = function()
		return math.floor(vim.o.lines * 0.75)
	end,
	max_width = function()
		return math.floor(vim.o.columns * 0.75)
	end,
	on_open = function(win)
		vim.api.nvim_win_set_config(win, { zindex = 100 })
	end,
})
