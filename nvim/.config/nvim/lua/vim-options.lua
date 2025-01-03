vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.o.ignorecase = true
vim.o.smartcase = true

-- Enable the sign column to prevent the screen from jumping
vim.opt.signcolumn = "yes"

-- Enable relative line numbers
vim.opt.nu = true
vim.opt.rnu = true

-- Always keep 8 lines above/below cursor unless at start/end of file
vim.opt.scrolloff = 8

vim.g.mapleader = " "

-- tmux config
vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { silent = true })
vim.keymap.set("n", "<C-\\>", "<Cmd>TmuxNavigateLastActive<CR>", { silent = true })
vim.keymap.set("n", "<C-Space>", "<Cmd>TmuxNavigateNavigateNext<CR>", { silent = true })

-- delete cursor letter
vim.keymap.set("n", "x", '"_x')

-- delete without copy
vim.keymap.set("n", "P", '"0p')

-- select the word
vim.keymap.set("n", "sc", "viw")

-- exclude the word and enter in insert mode
vim.keymap.set("n", "sd", "viwdi")

-- select the word and copy
vim.keymap.set("n", "sy", "viwy")

-- select the word and paste
vim.keymap.set("n", "sp", "viwp")

-- Delete a word backwards
vim.keymap.set("n", "dq", 'vb"_d')

-- Delete next word
vim.keymap.set("n", "dw", 've"_d')

-- Select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save file
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")

-- disable netrw file navigation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Split window
vim.keymap.set("n", "ss", ":split<Return>")
vim.keymap.set("n", "sv", ":vsplit<Return>")

-- Move window
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<C-j>", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- copy and paste
vim.api.nvim_set_option("clipboard", "unnamed")

local is_wsl = vim.fn.has("wsl") == 1

-- WSL Clipboard support
if is_wsl then
	-- This is NeoVim's recommended way to solve clipboard sharing if you use WSL
	-- See: https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
	vim.g.clipboard = {
		name = "WslClipboard",
		copy = {
			["+"] = "clip.exe",
			["*"] = "clip.exe",
		},
		paste = {
			["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
			["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
		},
		cache_enabled = 0,
	}
end
