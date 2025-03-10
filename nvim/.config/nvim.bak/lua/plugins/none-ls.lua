return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    -- Adding this as a dependency because some of the default lsps were removed
    -- See https://github.com/nvimtools/none-ls.nvim/discussions/81 for more information
    "nvimtools/none-ls-extras.nvim",
  },
event = { "BufReadPost", "BufNewFile" },
opts = function()
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		local lsp_formatting = function(buffer)
			vim.lsp.buf.format({
				filter = function(client)
					-- By default, ignore any formatters provider by other LSPs
					-- (such as those managed via lspconfig or mason)
					return client.name == "null-ls"
				end,
				bufnr = buffer,
			})
		end

		-- Format on save
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts#neovim-08
		local on_attach = function(client, buffer)
			-- the Buffer will be null in buffers like nvim-tree or new unsaved files
			if (not buffer) then
				return
			end

			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = augroup, buffer = buffer })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = buffer,
					callback = function()
						lsp_formatting(buffer)
					end,
				})
			end
		end
		local nls = require("null-ls")
		return {
			debug = true,
			sources = {
        nls.builtins.formatting.stylelint,
        nls.builtins.formatting.prettier,
        nls.builtins.formatting.biome,
        nls.builtins.formatting.gofmt,
        nls.builtins.formatting.goimports,

        nls.builtins.diagnostics.stylelint,
        nls.builtins.diagnostics.actionlint,
        nls.builtins.diagnostics.yamllint,
        nls.builtins.diagnostics.golangci_lint,
        require("none-ls.diagnostics.eslint"),

        nls.builtins.code_actions.impl,
        nls.builtins.code_actions.gomodifytags,
        require("none-ls.code_actions.eslint"),
			},
			on_attach = on_attach
		}
	end,
config = function(_, opts)
		require("null-ls").setup(opts)
	end,
}
