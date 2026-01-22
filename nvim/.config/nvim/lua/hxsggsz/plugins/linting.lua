return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local api = vim.api
		local fs = vim.fs
		local uv = vim.loop -- Necessário para vim.loop.fs_stat

		-- Arquivos de configuração do Biome a serem procurados
		local biome_config_files = {
			"biome.json",
			"biome.jsonc",
		}

		-- Define os filetypes que usarão a lógica de fallback Biome -> eslint_d
		local js_ts_fts = {
			javascript = true,
			typescript = true,
			javascriptreact = true,
			typescriptreact = true,
		}

		-- Função para encontrar a raiz do projeto (procurando por marcadores comuns)
		-- (Adaptada para incluir biome.json como marcador)
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
		-- (Reutilizada e adaptada da solução do conform.nvim)
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

			-- 1. Tenta encontrar subindo na árvore
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

		local lint_augroup = api.nvim_create_augroup("lint_biome_eslint_fallback", { clear = true }) -- Nome do grupo atualizado

		-- A lógica principal para linting condicional (Biome -> ESLint)
		local function run_conditional_lint(args)
			local bufnr = args and args.buf or api.nvim_get_current_buf()
			if not api.nvim_buf_is_valid(bufnr) then
				return
			end
			local ft = vim.bo[bufnr].filetype
			if not ft or ft == "" then
				return
			end

			if js_ts_fts[ft] then
				-- Verifica se o projeto usa Biome baseado na config
				if project_uses_biome(bufnr) then
					-- Se usa Biome, executa SOMENTE biomejs
					lint.try_lint({ "biomejs" }, { bufnr = bufnr })
				else
					-- Se não usa Biome, executa SOMENTE eslint_d como fallback
					-- lint.try_lint({ "eslint_d" }, { bufnr = bufnr })
					lint.try_lint(nil, { bufnr = bufnr })
				end
			else
				-- Para outros filetypes, usa o comportamento padrão do nvim-lint
				-- (Procura linters definidos em lint.linters_by_ft, se houver)
			end
		end

		-- Configura autocmds para disparar a função de linting condicional
		api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = run_conditional_lint,
		})

		-- Atualiza o keymap para também usar a lógica condicional
		vim.keymap.set("n", "<leader>!", function()
			run_conditional_lint({ buf = api.nvim_get_current_buf() })
		end, { desc = "[L]int: Disparar linter (Biome/ESLint)" }) -- Descrição atualizada

		-- Chama as code actions do ESLint com a mesma lógica do linting condicional
		local function run_eslint_code_actions()
			local bufnr = api.nvim_get_current_buf()
			local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
			if #clients == 0 then
				vim.notify("Nenhum LSP ativo para executar ações do ESLint", vim.log.levels.INFO)
				return
			end

			vim.lsp.buf.code_action({
				context = {
					diagnostics = vim.diagnostic.get(bufnr),
					only = { "source.fixAll.eslint", "source.fixAll" },
				},
			})
		end

		vim.keymap.set("n", "<leader>ce", run_eslint_code_actions, {
			desc = "[L]int: Ações do ESLint",
		})

		-- Opcional: Defina linters para outros filetypes aqui, se necessário
		-- A função run_conditional_lint cuidará deles através do lint.try_lint(nil, ...)
		-- lint.linters_by_ft = {
		--   markdown = { "vale" },
		--   python = { "ruff" },
		--   -- etc.
		-- }
	end,
}
