return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		local api = vim.api
		local fs = vim.fs
	local uv = vim.loop

	local biome_config_files = {
		"biome.json",
		"biome.jsonc",
	}
	local prettier_config_files = {
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

	-- ---[ Funções Auxiliares ]---

	local function find_project_root(start_path)
		local markers = { "package.json", ".git", "pyproject.toml", "biome.json", "biome.jsonc", "init.lua" }
		local found_markers = fs.find(markers, { upward = true, path = start_path, type = "file", limit = 1 })
		if #found_markers > 0 then
			return fs.dirname(found_markers[1])
		end
		local fallback_dir = fs.find({ ".git" }, { upward = true, path = start_path, type = "directory", limit = 1 })
		if #fallback_dir > 0 then
			return fs.dirname(fallback_dir[1])
		end
		return nil
	end

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

		local found_config_upward = fs.find(biome_config_files, {
			upward = true,
			path = current_dir,
			stop = search_stop_dir,
			type = "file",
			limit = 1,
		})

		if found_config_upward and #found_config_upward > 0 then
			return true
		end

		if root_dir then
			for _, config_file in ipairs(biome_config_files) do
				local full_path = root_dir .. "/" .. config_file
				if uv.fs_stat(full_path) then
					return true
				end
			end
		end
		return false
	end

	local function read_json_file(path)
		local file = io.open(path, "r")
		if not file then
			return nil
		end
		local content = file:read("*all")
		file:close()
		local ok, decoded = pcall(vim.json.decode, content)
		if not ok or type(decoded) ~= "table" then
			return nil
		end
		return decoded
	end

	local function package_json_has_prettier(path)
		local json = read_json_file(path)
		return json and json.prettier ~= nil
	end

	local function find_prettier_config_dir(start_dir)
		if not start_dir then
			return nil
		end
		local root = fs.root(start_dir, function(name, path)
			for _, config_name in ipairs(prettier_config_files) do
				if name == config_name then
					return true
				end
			end
			if name == "package.json" then
				local full_path = fs.joinpath(path, name)
				return package_json_has_prettier(full_path)
			end
			return false
		end)
		return root
	end

	local function project_has_prettier(bufnr)
		local buf_name = api.nvim_buf_get_name(bufnr)
		if buf_name == "" then
			return false
		end
		local current_dir = fs.dirname(buf_name)
		if not current_dir then
			return false
		end
		return find_prettier_config_dir(current_dir) ~= nil
	end

	local function biome_or_prettier_based_on_config(bufnr)
		if project_uses_biome(bufnr) then
			return { "biome" }
		end

		if project_has_prettier(bufnr) then
			return { "prettierd" }
		end

		return {}
	end

	local function get_prettierd_context_dir(ctx)
		local dir = ctx and ctx.dirname
		if not dir and ctx and ctx.filename then
			dir = fs.dirname(ctx.filename)
		end
		return dir
	end

	local function prettierd_root_dir(ctx)
		local dir = get_prettierd_context_dir(ctx)
		if not dir then
			return nil
		end
		return find_prettier_config_dir(dir) or find_project_root(dir) or dir
	end

		-- ---[ Setup do Conform ]---

		conform.setup({
			formatters = {
				prettierd = {
					inherit = true,
					cwd = function(_, ctx)
						return prettierd_root_dir(ctx)
					end,
				},
			},
			formatters_by_ft = {
				javascript = biome_or_prettier_based_on_config,
				typescript = biome_or_prettier_based_on_config,
				javascriptreact = biome_or_prettier_based_on_config,
				typescriptreact = biome_or_prettier_based_on_config,
				json = biome_or_prettier_based_on_config,
				jsonc = biome_or_prettier_based_on_config,
				css = { "prettierd" },
				html = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				liquid = { "prettierd" },
				go = { "goimports", "gofumpt" },
				lua = { "stylua" },
			},

			format_on_save = function(bufnr)
		local fallback = { timeout_ms = 1000, lsp_fallback = true }

		-- 1. Verifica se o gitsigns está disponível
		local ok, gitsigns = pcall(require, "gitsigns")
		if not ok then
			return fallback
		end

		-- 2. Busca os "hunks" (mudanças) do buffer
		local hunks = gitsigns.get_hunks(bufnr)
		if not hunks or #hunks == 0 then
			return fallback
		end

		-- 3. Calcula o início e o fim das alterações
		local first_change_line = nil
		local last_change_line = nil

		for _, hunk in ipairs(hunks) do
			if hunk.added and hunk.added.count > 0 then
				local start = hunk.added.start
				local count = hunk.added.count
				local ending = start + count

				if not first_change_line or start < first_change_line then
					first_change_line = start
				end
				if not last_change_line or ending > last_change_line then
					last_change_line = ending
				end
			end
		end

		if not first_change_line or not last_change_line then
			return fallback
		end

		-- 4. Retorna o range calculado
		return {
			timeout_ms = 1000,
			lsp_fallback = true,
			range = {
				start = { first_change_line, 0 },
				["end"] = { last_change_line, 0 },
			},
		}
			end,

			notify_on_error = true,
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
