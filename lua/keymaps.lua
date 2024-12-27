-- Move by visible lines
vim.keymap.set({ "n", "x" }, "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true })
vim.keymap.set({ "n", "x" }, "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Easier keys for exiting terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Save buffer
vim.keymap.set("n", "<C-S>", "<Cmd>silent! update | redraw<CR>", { desc = "Save" })
vim.keymap.set({ "i", "x" }, "<C-S>", "<Esc><Cmd>silent! update | redraw<CR>", { desc = "Save and go to Normal mode" })

-- Toggle line wrap with Alt-Z
vim.keymap.set("n", "<M-z>", "<Cmd>setlocal wrap!<CR>")

-- Execute
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", {desc = "E[x]ecute File"})
vim.keymap.set("n", "<leader>x", ":.lua<CR>", {desc = "E[x]ecute Line"})
vim.keymap.set("v", "<leader>x", ":lua<CR>", {desc = "E[x]ecute Selection"})

---- From mini.basics
-- Add empty lines before and after cursor line supporting dot-repeat
vim.keymap.set("n", "gO", "v:lua.MNvim.put_empty_line(v:true)", { expr = true, desc = "Put empty line above" })
vim.keymap.set("n", "go", "v:lua.MNvim.put_empty_line(v:false)", { expr = true, desc = "Put empty line below" })

-- Move with alt
-- Move only sideways in command mode. Using `silent = false` makes movements
-- to be immediately shown.
vim.keymap.set("c", "<M-h>", "<Left>", { silent = false, desc = "Left" })
vim.keymap.set("c", "<M-l>", "<Right>", { silent = false, desc = "Right" })

-- Don't `norevim.keymap.set` in insert mode to have these keybindings behave exactly
-- like arrows (crueial inside TelescopePrompt)
vim.keymap.set("i", "<M-h>", "<Left>", { noremap = false, desc = "Left" })
vim.keymap.set("i", "<M-j>", "<Down>", { noremap = false, desc = "Down" })
vim.keymap.set("i", "<M-k>", "<Up>", { noremap = false, desc = "Up" })
vim.keymap.set("i", "<M-l>", "<Right>", { noremap = false, desc = "Right" })

vim.keymap.set("t", "<M-h>", "<Left>", { desc = "Left" })
vim.keymap.set("t", "<M-j>", "<Down>", { desc = "Down" })
vim.keymap.set("t", "<M-k>", "<Up>", { desc = "Up" })
vim.keymap.set("t", "<M-l>", "<Right>", { desc = "Right" })
