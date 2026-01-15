return {
	"neovim/nvim-lspconfig",
	version = "v2.*",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"mason-org/mason-lspconfig.nvim",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local keymap = vim.keymap

		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local capabilities = cmp_nvim_lsp.default_capabilities()

		mason_lspconfig.setup({
			ensure_installed = { "lua_ls", "ts_ls", "gopls" }, -- Adicionei tsserver
			handlers = {
				-- Handler padrão para todos os LSPs
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,

				-- Configurações específicas
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
								completion = { callSnippet = "Replace" },
							},
						},
					})
				end,

				["gopls"] = function()
					lspconfig.gopls.setup({
						capabilities = capabilities,
						settings = {
							gopls = {
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
							},
						},
					})
				end,

				-- Novo handler para TypeScript
				["ts_ls"] = function()
					lspconfig.ts_ls.setup({})
				end,
			},
		})
	end,
}
