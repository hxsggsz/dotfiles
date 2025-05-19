return {
	"rose-pine/neovim",
	config = function()
		require("rose-pine").setup({})
		vim.cmd([[colorscheme rose-pine-main]])
	end,
}

-- vim.cmd([[colorscheme tokyonight]])
