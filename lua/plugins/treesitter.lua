return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
		lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		main = "nvim-treesitter.configs",
		opts_extend = { "ensure_installed" },
		---@type TSConfig
		opts = {
			ensure_installed = {
				"bash",
				"diff",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		opts = { mode = "cursor", max_lines = 3 },
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		opts = {
			enable_autocmd = false,
		},
	},
}
