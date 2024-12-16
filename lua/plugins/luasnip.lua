return {
	-- 	"mireq/luasnip-snippets",
	-- 	dependencies = { "L3MON4D3/LuaSnip" },
	-- 	init = function()
	-- 		-- Mandatory setup function
	-- 	end,
	-- }, {
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = "make install_jsregexp",
	config = function()
		local ls = require("luasnip")
		local i = ls.insert_node
		local s = ls.snippet
		local t = ls.text_node
		local sn = ls.snippet_node
		local d = ls.dynamic_node
		-- local su = require("luasnip_snippets.common.snip_utils")
		-- local nl = su.new_line
		-- local te = su.trig_engine
		ls.setup({
			-- Required to automatically include base snippets, like "c" snippets for "cpp"
			-- load_ft_func = require("luasnip_snippets.common.snip_utils").load_ft_func,
			-- ft_func = require("luasnip_snippets.common.snip_utils").ft_func,
			-- To enable auto expansin
			enable_autosnippets = true,
			-- Uncomment to enable visual snippets triggered using <c-x>
			-- store_selection_keys = '<c-x>',
		})
		-- LuaSnip key bindings
		vim.keymap.set({ "i", "s" }, "<Tab>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			else
				vim.api.nvim_input("<C-V><Tab>")
			end
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
			ls.jump(-1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-E>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true })

		ls.add_snippets("go", {
			-- s({ trig = "ir", descr = '(ir) "if error not nil, return err"', priority = 1000 }, {
			-- 	t("if "),
			-- 	i(0, "err", { key = "i0" }),
			-- 	t(" != nil {"),
			-- 	t({ "\treturn err", "}" }),
			-- 	i(1, "", { key = "i1" }),
			-- }),
			s("ir", {
				t("if "),
				i(1),
				t(" != nil {"),
				t({ "", "\treturn " }),
				d(2, function(args)
					-- the returned snippetNode doesn't need a position; it's inserted
					-- "inside" the dynamicNode.
					return sn(nil, {
						-- jump-indices are local to each snippetNode, so restart at 1.
						i(1, args[1]),
					})
				end, { 1 }),
				t({ "", "}" }),
				i(0),
			}),
		})
	end,
}
