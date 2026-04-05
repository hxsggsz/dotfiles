return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "lewis6991/gitsigns.nvim" },
	config = function()
		local conform = require("conform")

		local function find_config(bufnr, filenames)
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname == "" then
				return nil
			end

			local found = vim.fs.find(filenames, {
				path = bufname,
				upward = true,
				limit = 1,
			})
			return found[1]
		end

		local function has_biome(bufnr)
			return find_config(bufnr, { "biome.json", "biome.jsonc" }) ~= nil
		end

		local function has_prettier(bufnr)
			local prettier_configs = {
				".prettierrc",
				".prettierrc.json",
				".prettierrc.yml",
				".prettierrc.yaml",
				".prettierrc.json5",
				".prettierrc.js",
				".prettierrc.cjs",
				".prettierrc.mjs",
				".prettierrc.toml",
				"prettier.config.js",
				"prettier.config.cjs",
				"prettier.config.mjs",
			}

			if find_config(bufnr, prettier_configs) then
				return true
			end

			local package_json_path = find_config(bufnr, { "package.json" })
			if package_json_path then
				local file = io.open(package_json_path, "r")
				if file then
					local content = file:read("*a")
					file:close()
					local ok, decoded = pcall(vim.json.decode, content)
					if ok and decoded and decoded.prettier then
						return true
					end
				end
			end
			return false
		end

		local function js_ts_formatter(bufnr)
			if has_biome(bufnr) then
				return { "biome" }
			elseif has_prettier(bufnr) then
				return { "prettierd" }
			end
			return {}
		end

		conform.setup({
			formatters_by_ft = {
				javascript = js_ts_formatter,
				typescript = js_ts_formatter,
				javascriptreact = js_ts_formatter,
				typescriptreact = js_ts_formatter,
				json = js_ts_formatter,
				jsonc = js_ts_formatter,
				css = { "prettierd" },
				html = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				lua = { "stylua" },
				go = { "goimports", "gofmt" },
			},
		})

		local function format_changed_lines(bufnr)
			if vim.bo[bufnr].buftype ~= "" then
				return
			end

			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			local ok, gitsigns = pcall(require, "gitsigns")
			if not ok then
				conform.format({ bufnr = bufnr, lsp_fallback = true })
				return
			end

			local hunks = gitsigns.get_hunks(bufnr)
			if not hunks or #hunks == 0 then
				return
			end

			local last_line_in_buf = vim.api.nvim_buf_line_count(bufnr)

			for i = #hunks, 1, -1 do
				local hunk = hunks[i]
				if hunk and hunk.type ~= "delete" then
					local start_line = hunk.added.start
					local count = hunk.added.count

					if start_line == 0 then
						start_line = 1
					end

					local end_line = start_line + count

					if end_line > last_line_in_buf then
						end_line = last_line_in_buf
					end

					if start_line > end_line or start_line > last_line_in_buf then
						goto continue
					end

					local range = {
						start = { start_line, 0 },
						["end"] = { end_line, 0 },
					}

					local status, err = pcall(function()
						conform.format({
							bufnr = bufnr,
							range = range,
							lsp_fallback = true,
							timeout_ms = 500,
							async = false,
						})
					end)

					if not status then
						print("Erro ao formatar hunk: " .. err)
					end

					::continue::
				end
			end
		end

		vim.keymap.set("n", "<leader>mf", function()
			format_changed_lines(0)
		end, { desc = "Format modified lines" })

		vim.keymap.set("n", "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = true,
				timeout_ms = 1000,
			})
		end, { desc = "Format entire buffer" })
	end,
}
