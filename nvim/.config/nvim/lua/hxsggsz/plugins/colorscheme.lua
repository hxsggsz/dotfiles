return {
	"rose-pine/neovim",
	config = function()
	require("rose-pine").setup({
		variant = "auto",
		dark_variant = "main",
		light_variant = "dawn",
		dim_inactive_windows = false,
		extend_background_behind_borders = true,
		styles = {
			bold = true,
			transparency = true,
		},
	})

	local function sincronizar_pelo_arquivo_kitty()
		-- Caminho padrão onde o Kitty salva o tema atual
		-- Ajuste se o seu estiver em outro lugar
		local kitty_conf_path = os.getenv("HOME") .. "/.config/kitty/current-theme.conf"

		-- Tenta abrir o arquivo
		local file = io.open(kitty_conf_path, "r")

		if file then
			local content = file:read("*a") -- Lê o arquivo todo
			file:close()

			-- Procura pela palavra "Dawn" dentro do arquivo de configuração
			-- (Geralmente aparece nos comentários ou no nome do arquivo)
			if string.find(content, "Dawn") or string.find(content, "dawn") then
				vim.o.background = "light"
				vim.cmd("colorscheme rose-pine-dawn")
			else
				-- Se não tiver "Dawn", assume que é o Main (Dark)
				vim.o.background = "dark"
				vim.cmd("colorscheme rose-pine")
			end
		else
			-- Se não achar o arquivo, fallback seguro
			print("Arquivo de tema do Kitty não encontrado.")
		end
	end

	-- Roda ao iniciar
	sincronizar_pelo_arquivo_kitty()

	vim.api.nvim_create_user_command("TrocarTema", function()
		if vim.o.background == "dark" then
			-- ==========================================
			-- MUDAR PARA LIGHT (Dawn)
			-- ==========================================
			vim.o.background = "light"
			-- Aplica o tema Light padrão e recarrega
			vim.fn.system("kitten themes --reload-in=all 'Rosé Pine Dawn'")
			print("Mudado para Light (Dawn)")
		else
			-- ==========================================
			-- MUDAR PARA DARK (Main + Pitch Black)
			-- ==========================================
			vim.o.background = "dark"
			vim.fn.system("kitten themes --reload-in=all 'Rosé Pine'")
		end
	end, {})

	-- Mantém seu atalho
	vim.keymap.set("n", "<leader>tt", ":TrocarTema<CR>", { desc = "Alternar Dark/Light" })
	end,
}
