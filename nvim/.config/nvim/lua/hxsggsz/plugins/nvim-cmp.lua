return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"brenoprata10/nvim-highlight-colors",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind.nvim",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local format_item_with_lspkind = require("lspkind").cmp_format({
				mode = "symbol_text",
				maxwidth = 50,
				ellipsis_char = "...",
				menu = {
					nvim_lsp = "[LSP]",
					buffer = "[Buffer]",
					path = "[Path]",
					luasnip = "[Snippet]",
					nvim_lsp_signature_help = "[Signature]",
				},
			})

			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable(1) then
							luasnip.expand_or_jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-e>"] = cmp.mapping.abort(), -- close completion window
					["<C-u>"] = cmp.mapping.scroll_docs(-4), -- scroll up preview
					["<C-d>"] = cmp.mapping.scroll_docs(4), -- scroll down preview
					["<C-Space>"] = cmp.mapping.complete({}), -- show completion suggestions
					["<CR>"] = cmp.mapping(function(fallback) -- select suggestion or snippet
						if cmp.visible() then
							if luasnip.expandable() then
								luasnip.expand()
							else
								cmp.confirm({
									select = true,
								})
							end
						else
							fallback()
						end
					end),
				}),

				-- sources for autocompletion
				sources = cmp.config.sources({
					{ name = "nvim_lsp", group_index = 1 }, -- lsp
					{ name = "buffer", max_item_count = 5, group_index = 2 }, -- text within current buffer
					{ name = "path", max_item_count = 3, group_index = 3 }, -- file system paths
					{ name = "luasnip", max_item_count = 3, group_index = 5 }, -- snippets
					{ name = "nvim-lsp-signature-help" },
				}),
				-- Enable pictogram icons for lsp/autocompletion
				formatting = {
					expandable_indicator = true,
					format = function(entry, item)
						local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
						item = format_item_with_lspkind(entry, item)

						if color_item.abbr_hl_group then
							item.kind_hl_group = color_item.abbr_hl_group
							item.kind = color_item.abbr
						end

						return item
					end,
				},
				experimental = {
					ghost_text = true,
				},
			})
		end,
	},
}
