-- nvim-lspconfig + mason stack (migrated from lazy.nvim to vim.pack).
-- cmp-nvim-lsp is included here because this file loads before the cmp file
-- (alphabetical) and the capabilities below require it. nvim-cmp is added first
-- so `cmp` is on rtp before cmp-nvim-lsp's after/plugin script requires it.
vim.pack.add({
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/neovim/nvim-lspconfig",
})

-- Useful status updates for LSP.
require("fidget").setup({})

--  This function gets run when an LSP attaches to a particular buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
		map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
		map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
		map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
		map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
		map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
		map("<leader>pv", vim.lsp.buf.rename, "Re[p]lace [v]ariable")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.server_capabilities.documentHighlightProvider then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

-- Custom gopls config (adapted from nvim-lspconfig's server_configurations/gopls.lua)
local configs = require("lspconfig.configs")
local util = require("lspconfig.util")
local async = require("lspconfig.async")
-- mod_cache initially set to `go env GOMODCACHE`
local mod_cache = "/root/go/pkg/mod"

configs.gopls = {
	default_config = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_dir = function(fname)
			-- see: https://github.com/neovim/nvim-lspconfig/issues/804
			if not mod_cache then
				local result = async.run_command("go env GOMODCACHE")
				if result and result[1] then
					mod_cache = vim.trim(result[1])
				end
			end
			if fname:sub(1, #mod_cache) == mod_cache then
				local clients = vim.lsp.get_active_clients({ name = "gopls" })
				if #clients > 0 then
					return clients[#clients].config.root_dir
				end
			end
			return util.root_pattern("go.work")(fname) or util.root_pattern("go.mod", ".git")(fname)
		end,
		single_file_support = true,
	},
	docs = {
		description = [[
  https://github.com/golang/tools/tree/master/gopls

  Google's lsp server for golang.
  ]],
		default_config = {
			root_dir = [[root_pattern("go.work", "go.mod", ".git")]],
		},
	},
}

-- Broadcast nvim-cmp capabilities to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

-- Enable the following language servers (installed automatically via mason).
local servers = {
	gopls = {
		settings = {
			gopls = {
				completeUnimported = true,
				usePlaceholders = true,
				buildFlags = { "-tags=integration" },
			},
		},
	},
	pylsp = {
		enable = false,
		configurationSources = { "flake8" },
		plugins = {
			black = { enabled = false },
			flake8 = {
				enabled = false,
				ignore = { "BLK100", "E1", "E2", "E3", "E5", "I", "W291" },
				executable = ".venv/bin/flake8",
			},
			jedi = { environment = ".venv/bin/python" },
			mccabe = { enabled = false },
			mypy = { enabled = false },
			pycodestyle = { enabled = false },
			pydocstyle = { enabled = false },
			pyflakes = { enabled = false },
			pylint = { enabled = false },
			rope_autoimport = { enabled = true },
			yapf = { enabled = false },
			ruff = { enabled = true },
		},
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
		end,
	},
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					library = {
						"${3rd}/luv/library",
						unpack(vim.api.nvim_get_runtime_file("", true)),
					},
				},
				completion = {
					callSnippet = "Replace",
				},
			},
		},
	},
}

require("mason").setup()

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
	"stylua", -- Used to format lua code
})
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

require("mason-lspconfig").setup({
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}
			server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
			require("lspconfig")[server_name].setup(server)
		end,
	},
})
