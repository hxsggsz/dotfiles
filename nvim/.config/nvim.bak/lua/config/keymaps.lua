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

-- Split window
vim.keymap.set("n", "ss", ":split<Return>")
vim.keymap.set("n", "sv", ":vsplit<Return>")

-- Move window
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
