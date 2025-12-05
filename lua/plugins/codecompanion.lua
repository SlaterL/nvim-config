return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		opts = {
			log_level = "DEBUG", -- or "TRACE"
		},
	},
	config = function()
		local cc = require("codecompanion")

		cc.setup({
			strategies = {
				-- Map both chat and inline completions to Ollama
				chat = {
					adapter = "ollama",
					model = "gwen3-coder:30b",
				},
				inline = {
					adapter = "ollama",
					model = "gwen3-coder:30b",
				},
			},
			memory = {
				default = {
					description = "Memory files for Ollama Code users",
					files = {
						"~/Documents/llm/ollama.md",
					},
				},
			},
		})
	end,
}
