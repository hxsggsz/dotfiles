-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- tmux config
vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { silent = true })
vim.keymap.set("n", "<C-\\>", "<Cmd>TmuxNavigateLastActive<CR>", { silent = true })
vim.keymap.set("n", "<C-Space>", "<Cmd>TmuxNavigateNavigateNext<CR>", { silent = true })

-- Select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save file
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")

-- Split window
vim.keymap.set("n", "ss", ":split<Return>")
vim.keymap.set("n", "sv", ":vsplit<Return>")

-- Move window
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")
