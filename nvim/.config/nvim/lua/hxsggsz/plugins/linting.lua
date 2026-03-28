return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local api = vim.api
		local fs = vim.fs

	-- === [ 1. Configuração do eslint_d ] ===
	local eslint = lint.linters.eslint_d

		-- Argumentos para forçar JSON limpo e evitar erros de parse
		eslint.args = {
			"--format", "json",
			"--stdin",
			"--stdin-filename",
			function() 																		return api.nvim_buf_get_name(0)
end,
		}

		-- === [ 2. Funções Auxiliares ] ===
		
		-- Encontra a raiz do projeto (onde está package.json ou .git)
		local function get_project_root(bufnr)
		local bufname = api.nvim_buf_get_name(bufnr)
		if bufname == "" then
			return vim.loop.cwd()
		end
			
			local root = fs.find({ "package.json", ".git", ".eslintrc.js", ".eslintrc.json" }, {
				path = bufname,
				upward = true,
				limit = 1
			})[1]

		return root and fs.dirname(root) or vim.loop.cwd()
		end

		local function project_uses_biome(bufnr)
		local bufname = api.nvim_buf_get_name(bufnr)
		if bufname == "" then
			return false
		end
		local root = fs.find({ "biome.json", "biome.jsonc" }, {
			path = bufname,
			upward = true,
			limit = 1,
		})[1]
		return root ~= nil
		end

	-- === [ 3. Lógica de Execução ] ===

	local lint_augroup = api.nvim_create_augroup("lint_biome_eslint_fallback", { clear = true })
	local js_ts_fts = { javascript = true, typescript = true, javascriptreact = true, typescriptreact = true }

		local function run_conditional_lint(args)
		local bufnr = args.buf
		if not api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then
			return
		end
			
			local ft = vim.bo[bufnr].filetype

		-- Define o diretório de trabalho correto para o linter encontrar as configs
		local root_dir = get_project_root(bufnr)
		local opts = { cwd = root_dir, bufnr = bufnr }

			if js_ts_fts[ft] then
				if project_uses_biome(bufnr) then
				lint.try_lint("biomejs", opts)
				else
				lint.try_lint("eslint_d", opts)
				end
			else
			lint.try_lint(nil, opts)
			end
		end

		api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
			group = lint_augroup,
			callback = run_conditional_lint,
		})
	end,
}
