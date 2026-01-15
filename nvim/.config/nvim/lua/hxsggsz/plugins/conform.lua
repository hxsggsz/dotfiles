return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		local api = vim.api
		local fs = vim.fs
		local uv = vim.loop -- Para usar vim.loop.fs_stat

		local biome_config_files = {
			"biome.json",
			"biome.jsonc",
		}

		-- Função para encontrar a raiz do projeto
		local function find_project_root(start_path)
			local markers = { "package.json", ".git", "pyproject.toml", "biome.json", "biome.jsonc", "init.lua" }
			local found_markers = fs.find(markers, { upward = true, path = start_path, type = "file", limit = 1 })
			if #found_markers > 0 then
				return fs.dirname(found_markers[1])
			end
			local fallback_dir = fs.find(
				{ ".git" },
				{ upward = true, path = start_path, type = "directory", limit = 1 }
			)
			if #fallback_dir > 0 then
				return fs.dirname(fallback_dir[1])
			end
			return nil
		end

		-- Função para verificar se existe um arquivo de config do Biome no projeto
		local function project_uses_biome(bufnr)
			local buf_name = api.nvim_buf_get_name(bufnr)
			if buf_name == "" then
				return false
			end

			local current_dir = fs.dirname(buf_name)
			if not current_dir then
				return false
			end

			local root_dir = find_project_root(current_dir)
			local search_stop_dir = root_dir

			-- 1. Tenta encontrar subindo na árvore (parando antes ou na raiz)
			local found_config_upward = fs.find(biome_config_files, {
				upward = true,
				path = current_dir,
				stop = search_stop_dir,
				type = "file",
				limit = 1,
			})

			if found_config_upward and #found_config_upward > 0 then
				return true -- Encontrou subindo
			end

			-- 2. Se não encontrou subindo E temos uma raiz, verifica diretamente na raiz
			if root_dir then
				for _, config_file in ipairs(biome_config_files) do
					local full_path = root_dir .. "/" .. config_file
					if uv.fs_stat(full_path) then
						return true -- Encontrou na raiz
					end
				end
			end

			-- 3. Se nenhuma das buscas encontrou, retorna false
			return false
		end

		-- Função condicional: usa Biome se config existir, senão usa Prettier
		local function biome_or_prettier_based_on_config(bufnr)
			if project_uses_biome(bufnr) then
				return { "biome" }
			else
				return { "prettier" }
			end
		end

		-- Configuração do conform.nvim
		conform.setup({
			formatters_by_ft = {
				javascript = biome_or_prettier_based_on_config,
				typescript = biome_or_prettier_based_on_config,
				javascriptreact = biome_or_prettier_based_on_config,
				typescriptreact = biome_or_prettier_based_on_config,
				json = biome_or_prettier_based_on_config,
				jsonc = biome_or_prettier_based_on_config,

				css = { "prettier" },
				html = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				liquid = { "prettier" },

				go = { "goimports", "gofumpt" },

				lua = { "stylua" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
			-- log_level = vim.log.levels.WARN, -- Ou ERROR, para menos mensagens
			notify_on_error = true, -- Manter notificação em caso de erro
		})

		-- Keymap para formatação manual
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
