return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
	local conform = require("conform")

	-- Função auxiliar para encontrar arquivos subindo na árvore de diretórios
	local function find_config(bufnr, filenames)
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if bufname == "" then
			return nil
		end

		-- vim.fs.find busca do diretório do buffer para cima (upward)
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
		-- Lista de configs explícitas do Prettier
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

		-- Verificação extra no package.json
		local package_json_path = find_config(bufnr, { "package.json" })
		if package_json_path then
			-- Lendo o arquivo de forma segura
			local file = io.open(package_json_path, "r")
			if file then
				local content = file:read("*a")
				file:close()
				local ok, decoded = pcall(vim.json.decode, content)
				-- Verifica se existe a chave "prettier" no package.json
				if ok and decoded and decoded.prettier then
					return true
				end
			end
		end
		return false
	end

	-- Seletor dinâmico de formatadores
	local function get_formatter(bufnr)
		if has_biome(bufnr) then
			return { "biome" }
		elseif has_prettier(bufnr) then
			return { "prettierd" }
		end
		return {} -- Retorna vazio para cair no fallback do LSP
	end

	-- ------

	conform.setup({
		formatters_by_ft = {
			javascript = get_formatter,
			typescript = get_formatter,
			javascriptreact = get_formatter,
			typescriptreact = get_formatter,
			json = get_formatter,
			jsonc = get_formatter,
			css = { "prettierd" },
			html = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },
			lua = { "stylua" },
			go = { "goimports", "gofumpt" },
		},
		-- NÃO usar format_on_save aqui, pois usaremos o autocmd customizado abaixo
	})

	-- ---[ 3. Implementação da "Estratégia A" (Gitsigns Hunks) ]---

	local function format_changed_lines(bufnr)
		-- Ignora buffers especiais
		if vim.bo[bufnr].buftype ~= "" then
			return
		end

		-- Verifica se o buffer ainda é válido antes de começar
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		local ok, gitsigns = pcall(require, "gitsigns")
		if not ok then
			require("conform").format({ bufnr = bufnr, lsp_fallback = true })
			return
		end

		local hunks = gitsigns.get_hunks(bufnr)
		if not hunks or #hunks == 0 then
			return
		end

		local last_line_in_buf = vim.api.nvim_buf_line_count(bufnr)

		-- Itera sobre os hunks
		for i = #hunks, 1, -1 do
			local hunk = hunks[i]
			if hunk and hunk.type ~= "delete" then
				local start_line = hunk.added.start
				local count = hunk.added.count

				-- Ajuste para hunks que começam na linha 0 (novos arquivos)
				if start_line == 0 then
					start_line = 1
				end

				local end_line = start_line + count

				-- [CORREÇÃO CRÍTICA]: O end_line nunca pode ser maior que o total de linhas
				if end_line > last_line_in_buf then
					end_line = last_line_in_buf
				end

				-- Se, por algum motivo, o inicio for maior que o fim ou maior que o arquivo, pula
				if start_line > end_line or start_line > last_line_in_buf then
					goto continue
				end

				-- Configura o range.
				-- Importante: end_line no conform geralmente espera a linha *após* o fim para ser inclusivo até o final da linha anterior,
				-- mas isso causa o crash no final do arquivo. Vamos usar o próprio end_line com coluna final.
				local range = {
					start = { start_line, 0 },
					["end"] = { end_line, 0 },
				}

				-- [PROTEÇÃO MÁXIMA]: Envolvemos o comando em pcall.
				-- Se o conform tentar acessar um index inválido, ele vai falhar silenciosamente
				-- em vez de jogar o erro na sua cara.
				local status, err = pcall(function()
					require("conform").format({
						bufnr = bufnr,
						range = range,
						lsp_fallback = true,
						timeout_ms = 500,
						async = false,
					})
				end)

				-- Opcional: Se quiser saber se falhou (debug), descomente abaixo:
				if not status then
					print("Erro ao formatar hunk: " .. err)
				end

				::continue::
			end
		end
	end

	-- Cria o Autocommand
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function(args)
			format_changed_lines(args.buf)
		end,
	})

	-- Atalho para forçar formatação total manualmente
	vim.keymap.set({ "n", "v" }, "<leader>mp", function()
		conform.format({
			lsp_fallback = true,
			async = true,
			timeout_ms = 1000,
		})
	end, { desc = "Format file or range (force full)" })
    end,
}
