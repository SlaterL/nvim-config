-- codecompanion.nvim (migrated from lazy.nvim to vim.pack)
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },
	"https://github.com/olimorris/codecompanion.nvim",
})

require("codecompanion").setup({
	opts = {
		log_level = "DEBUG", -- or "TRACE"
	},
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
