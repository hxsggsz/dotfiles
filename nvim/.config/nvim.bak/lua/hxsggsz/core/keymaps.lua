-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>h", "<Cmd>wincmd h<CR>", { desc = "Move cursor to left window" })
keymap.set("n", "<leader>j", "<Cmd>wincmd j<CR>", { desc = "Move cursor to bottomw window" })
keymap.set("n", "<leader>k", "<Cmd>wincmd k<CR>", { desc = "Move cursor to top window" })
keymap.set("n", "<leader>l", "<Cmd>wincmd l<CR>", { desc = "Move cursor to right window" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- copy to clipboard
keymap.set("v", "<C-c>", [["+y]])

-- tmux config
keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { silent = true })
keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { silent = true })
keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { silent = true })
keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { silent = true })
keymap.set("n", "<C-\\>", "<Cmd>TmuxNavigateLastActive<CR>", { silent = true })
keymap.set("n", "<C-Space>", "<Cmd>TmuxNavigateNavigateNext<CR>", { silent = true })

-- bufferline
keymap.set("n", "<S-l>", "<cmd> BufferLineCycleNext <CR>") --"  cycle next buffer"
keymap.set("n", "<S-h>", "<cmd> BufferLineCyclePrev <CR>") --"  cycle prev buffer"
keymap.set("n", "<tab>", "<cmd> BufferLineMoveNext <CR>") --"  cycle next buffer"
keymap.set("n", "<S-tab>", "<cmd> BufferLineMovePrev <CR>") --"  cycle prev buffer"
-- Select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save file
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")

-- Split window
-- vim.keymap.set("n", "ss", ":split<Return>")
-- vim.keymap.set("n", "sv", ":vsplit<Return>")

-- Move window
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")
