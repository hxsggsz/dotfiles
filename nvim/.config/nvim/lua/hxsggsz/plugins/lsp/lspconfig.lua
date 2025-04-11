return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"williamboman/mason-lspconfig.nvim",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Certifique-se de que 'keymap' está definido (geralmente no início do seu init.lua)
		local keymap = vim.keymap

		-- Cria um grupo de autocomandos para configurações LSP
		local lsp_augroup = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

		-- Define o autocomando que será executado quando um servidor LSP se anexar a um buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = lsp_augroup,
			desc = "Setup LSP keybinds and settings on attach",
			callback = function(ev)
				-- 'ev' contém informações sobre o evento, incluindo ev.buf (número do buffer)

				-- Opções comuns para mapeamentos locais ao buffer
				local opts = { buffer = ev.buf, silent = true }

				-- Mapeamentos Genéricos do LSP (definidos primeiro)
				-- ----------------------------------------------------
				opts.desc = "Show LSP references (Telescope)"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions (Telescope)"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Show LSP implementations (Telescope)"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions (Telescope)"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics (Telescope)"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- bufnr=0 pega o buffer atual

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- Requer :LspRestart (e.g., de nvim-lspconfig)

				-- Mapeamentos Específicos do TypeScript (ou que usam execute_command/code_action)
				-- Estes serão definidos *depois* dos genéricos. Se houver sobreposição (gD, gR),
				-- estas versões terão precedência *neste buffer*.
				-- ----------------------------------------------------

				-- Sobrescreve gD genérico com a versão específica 'goToSourceDefinition'
				opts.desc = "Goto Source Definition (TS)"
				keymap.set("n", "gD", function()
					local params = vim.lsp.util.make_position_params(ev.buf) -- Usa ev.buf
					-- Tenta executar o comando específico do TS
					-- Precisamos verificar se o cliente suporta este comando, idealmente.
					-- Mas para simplificar, vamos apenas tentar executá-lo.
					vim.lsp.buf_execute_command({
						command = "typescript.goToSourceDefinition",
						arguments = { params.textDocument.uri, params.position },
						bufnr = ev.buf, -- Usa o buffer do evento!
					})
				end, opts)

				-- Sobrescreve gR genérico com vim.lsp.buf.references() (alternativa ao Telescope)
				-- Se preferir o Telescope gR sempre, comente ou remova este bloco.
				opts.desc = "File References (nvim-lsp)"
				keymap.set("n", "gR", vim.lsp.buf.references, opts)

				-- Organizar Imports
				opts.desc = "Organize Imports (TS/JS)"
				keymap.set("n", "<leader>co", function()
					vim.lsp.buf.code_action({
						context = { only = { "source.organizeImports" } },
						apply = true,
						bufnr = ev.buf, -- Especifica o buffer
					})
				end, opts)

				-- Adicionar Imports Faltantes
				opts.desc = "Add missing imports (TS)"
				keymap.set("n", "<leader>cM", function()
					vim.lsp.buf.code_action({
						context = { only = { "source.addMissingImports.ts" } },
						apply = true,
						bufnr = ev.buf,
					})
				end, opts)

				-- Remover Imports Não Usados
				opts.desc = "Remove unused imports (TS)"
				keymap.set("n", "<leader>cu", function()
					vim.lsp.buf.code_action({
						context = { only = { "source.removeUnused.ts" } },
						apply = true,
						bufnr = ev.buf,
					})
				end, opts)

				-- Corrigir Todos os Diagnósticos
				opts.desc = "Fix all diagnostics (TS)"
				keymap.set("n", "<leader>fa", function()
					vim.lsp.buf.code_action({
						-- Tenta ambos os kinds comuns para 'fixAll'
						context = { only = { "source.fixAll.ts", "source.fixAll" } },
						apply = true,
						bufnr = ev.buf,
					})
				end, opts)

				-- Selecionar Versão do Workspace TS
				opts.desc = "Select TS workspace version"
				keymap.set("n", "<leader>cV", function()
					vim.lsp.buf_execute_command({
						command = "typescript.selectTypeScriptVersion",
						bufnr = ev.buf, -- Usa o buffer do evento!
					})
				end, opts)

				-- (Opcional) Adicionar aqui outras configurações/mapeamentos específicos do LSP
				-- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
				-- vim.bo[ev.buf].tagfunc = vim.lsp.tagfunc
			end, -- Fim do callback
		}) -- Fim do nvim_create_autocmd

		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,

			["lua_ls"] = function()
				-- configure lua server (with special settings)
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				})
			end,
		})
	end,
}
