return {
	-- Gitsigns
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		opts = {
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end

				-- Navigation
				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end)

				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end)
				map("n", "]H", function()
					gitsigns.nav_hunk("last")
				end, "Last Hunk")
				map("n", "[H", function()
					gitsigns.nav_hunk("first")
				end, "First Hunk")

				-- Actions
				map({ "n", "v" }, "<leader>ghs", gitsigns.stage_hunk, "Stage Hunk")
				map({ "n", "v" }, "<leader>ghr", gitsigns.reset_hunk, "Reset Hunk")
				map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage Buffer")
				map("n", "<leader>ghu", gitsigns.undo_stage_hunk, "Undo Stage Hunk")
				map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset Buffer")
				map("n", "<leader>ghp", gitsigns.preview_hunk_inline, "Preview Hunk Inline")
				map("n", "<leader>ghb", function()
					gitsigns.blame_line({ full = true })
				end, "Blame Line")
				map("n", "<leader>ghB", function()
					gitsigns.blame()
				end, "Blame Buffer")
				map("n", "<leader>ghd", gitsigns.diffthis, "Diff This")
				map("n", "<leader>ghD", function()
					gitsigns.diffthis("~")
				end, "Diff This ~")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
			end,
		},
	},

	-- Tabpage interface
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{ "<Leader>gd", "<cmd>DiffviewFileHistory %<CR>", desc = "[g]it [d]iff file" },
			{ "<Leader>gv", "<cmd>DiffviewOpen<CR>", desc = "[g]it [d]iff view" },
		},
		opts = {
			enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
		},
	},

	-- Git
	{
		"NeogitOrg/neogit",
		lazy = true,
		cmd = "Neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			MNvim.config.picker == "telescope" and "nvim-telescope/telescope.nvim" or "ibhagwan/fzf-lua",
		},
		keys = {
			{ "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
		},
		opts = {
			disable_signs = false,
			disable_context_highlighting = false,
			disable_commit_confirmation = false,
			signs = {
				section = { ">", "v" },
				item = { ">", "v" },
				hunk = { "", "" },
			},
			integrations = {
				diffview = true,
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" } },
	},
}
