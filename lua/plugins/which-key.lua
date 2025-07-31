return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VeryLazy", -- Sets the loading event to 'VeryLazy'
	config = function() -- This is the function that runs, AFTER loading
		require("which-key").setup()
		--
		-- Document existing key chains
		local wk = require("which-key")
		wk.add({
			{ "<leader>s", group = "Search" }, -- group
			{ "<leader>c", group = "Code" }, -- group
			{ "<leader>p", group = "Replace" }, -- group
			{ "<leader>d", group = "Document" }, -- group
			{ "<leader>r", group = "Rename" }, -- group
			{ "<leader>h", group = "Harpoon" }, -- group
			{ "<leader>G", group = "Git" }, -- group
			{ "<leader>j", group = "Jump" }, -- group
			{ "<leader>w", group = "Workspace" }, -- group
		})
	end,
}
