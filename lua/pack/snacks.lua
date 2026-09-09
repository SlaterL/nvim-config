-- snacks.nvim – fuzzy picker, replacing telescope.nvim + extensions.
-- Provides: files, grep, help, keymaps, diagnostics, resume, git pickers,
-- LSP pickers, and current-buffer lines. Also overrides vim.ui.select.
vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
	picker = {
		enabled = true,
		win = {
			input = {
				keys = {
					-- Custom keybindings for preview scrolling inside the input window
					["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
					["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
				},
			},
		},
		layout = {
			preset = "telescope",
		},
		-- 2. Define custom layout configurations here
		layouts = {
			telescope = {
				reverse = true,
				layout = {
					box = "horizontal",
					backdrop = true,
					width = 0.9,
					height = 0.9,
					-- border = "none",
					{
						box = "vertical",
						{ win = "list", title = " Results ", title_pos = "center", border = true },
						{
							win = "input",
							height = 1,
							border = true,
							title = "{title} {live} {flags}",
							title_pos = "center",
						},
					},
					{
						win = "preview",
						title = "{preview:Preview}",
						width = 0.65,
						border = true,
						title_pos = "center",
					},
				},
			},
		},
	},

	-- Explicitly disable components we don't use, so they don't clash with
	-- existing plugins (nvim-notify handles notifications, alpha/dashboard.lua
	-- handles the start screen, etc.)
	bigfile = { enabled = false },
	dashboard = {
		enabled = true,
		-- Override dashboard sections to exclude lazy.stats dependent components
		sections = {
			{ section = "header" },
			{
				section = "keys",
				gap = 1,
				padding = 1,
				-- Filter out the :Lazy key item if using default preset keys
				filter = function(item)
					return item.action ~= ":Lazy"
				end,
			},
		},
	},
	explorer = { enabled = false },
	indent = { enabled = false },
	input = { enabled = false },
	notifier = { enabled = false },
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	terminal = { enabled = false },
	words = { enabled = false },
})

-- [[ Keymaps ]] See `:help snacks-picker`
-- All keymaps use lambdas so Snacks.picker is resolved at call-time (after setup).
vim.keymap.set("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", function()
	Snacks.picker.resume()
end, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>si", function()
	Snacks.picker.lines()
end, { desc = "[S]earch [I]nside current file" })

-- Git
vim.keymap.set("n", "<leader>Gc", function()
	Snacks.picker.git_log()
end, { desc = "[G]it [C]ommits" })
vim.keymap.set("n", "<leader>Gs", function()
	Snacks.picker.git_status()
end, { desc = "[G]it [S]tatus" })
