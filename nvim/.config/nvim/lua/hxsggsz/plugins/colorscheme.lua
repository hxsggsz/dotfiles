return {
	"rose-pine/neovim",
	config = function()
		require("rose-pine").setup({
			styles = {
				bold = true,
				italic = false,
				transparency = true,
			},
		})
		vim.cmd([[colorscheme rose-pine-main]])
	end,
}

-- vim.cmd([[colorscheme tokyonight]])
