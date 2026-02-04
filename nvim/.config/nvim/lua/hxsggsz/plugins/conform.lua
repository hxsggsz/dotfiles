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
		-- Ignora buffers especiais (ex: janelas de log, terminal)
		if vim.bo[bufnr].buftype ~= "" then
			return
		end

		-- Dependência obrigatória: gitsigns
		local ok, gitsigns = pcall(require, "gitsigns")
		if not ok then
			-- Fallback silencioso: formata tudo se gitsigns falhar
			conform.format({ bufnr = bufnr, lsp_fallback = true })
			return
		end

		local hunks = gitsigns.get_hunks(bufnr)

		-- Se não houver mudanças git (arquivo comitado ou não rastreado), formata tudo
		if not hunks or #hunks == 0 then
			-- Opcional: Se quiser formatar o arquivo inteiro quando não houver diffs, descomente:
			-- conform.format({ bufnr = bufnr, lsp_fallback = true, timeout_ms = 1000 })
			return
		end

		local format_opts = {
			lsp_fallback = true,
			timeout_ms = 1000,
			async = false, -- Síncrono é crucial aqui para evitar conflitos de edição
		}

		-- Itera sobre os hunks de trás para frente (reverse)
		-- Isso evita que a formatação de linhas superiores desloque as inferiores
		for i = #hunks, 1, -1 do
			local hunk = hunks[i]
			if hunk and hunk.type ~= "delete" then
				local start_line = hunk.added.start
				local end_line = start_line + hunk.added.count

				-- Proteção: garante que não ultrapasse o fim do arquivo
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				if start_line > line_count then
					goto continue
				end
				end_line = math.min(end_line, line_count)

				-- Configura o range (LSP usa índice 0)
				local range = {
					start = { start_line - 1, 0 },
					["end"] = { end_line, 0 },
				}

				conform.format(vim.tbl_extend("force", format_opts, {
					bufnr = bufnr,
					range = range,
				}))

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
