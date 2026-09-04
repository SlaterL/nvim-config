-- nvim-cmp + LuaSnip completion stack (migrated from lazy.nvim to vim.pack)

-- Replaces lazy LuaSnip `build = "make install_jsregexp"` (regex support in
-- snippets). Skipped on Windows / when make is unavailable. Non-blocking:
-- PackChanged fires inside vim.pack's async loop, so never :wait() there.
if vim.fn.has("win32") == 0 and vim.fn.executable("make") == 1 then
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			if ev.data.spec.name == "LuaSnip" and ev.data.kind ~= "delete" then
				local path = ev.data.path
				vim.schedule(function()
					vim.system({ "make", "install_jsregexp" }, { cwd = path })
				end)
			end
		end,
	})
end

-- Order matters: nvim-cmp (provides the `cmp` module) must be added before the
-- cmp source plugins, whose after/plugin scripts `require("cmp")` at load time.
vim.pack.add({
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/saadparwaiz1/cmp_luasnip",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-path",
})

-- See `:help cmp`
local cmp = require("cmp")
local luasnip = require("luasnip")
luasnip.config.setup({})

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	preselect = "none",
	completion = { completeopt = "menu,menuone,noinsert" },

	-- For an understanding of why these mappings were chosen, see `:help ins-completion`
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-l>"] = cmp.mapping.complete({}),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
	},
})
