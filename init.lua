vim.g.mapleader = " "
vim.g.maplocalleader = " "

MNvim = require("mnvim").with_config({
	colorscheme = "moonbow",
	picker = "telescope",
})

require("options")
require("keymaps")
require("autocmds")

require("lazynvim")
