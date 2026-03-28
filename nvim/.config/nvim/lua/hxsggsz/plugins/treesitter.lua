return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
	-- Voltamos ao require padrão que funciona na versão estável
	local configs = require("nvim-treesitter.configs")

	configs.setup({
		ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"query",
			"markdown",
			"markdown_inline",
			"javascript",
			"typescript",
			"tsx",
			"bash",
			"json",
		},
		sync_install = false,
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
	})
    end,
}
