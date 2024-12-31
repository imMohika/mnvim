return {
	---- fzf
	--- TODO
	---- Telescope
	{
		"nvim-telescope/telescope.nvim",
		enabled = function()
			return MNvim.config.picker == "telescope"
		end,
		cmd = "Telescope",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
		opts = function()
			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin")

			local find_files_no_ignore = function()
				local action_state = require("telescope.actions.state")
				local line = action_state.get_current_line()
				builtin.find_files({ no_ignore = true, default_text = line })
			end

			local find_files_with_hidden = function()
				local action_state = require("telescope.actions.state")
				local line = action_state.get_current_line()
				builtin.find_files({ hidden = true, default_text = line })
			end

			local function find_command()
				if 1 == vim.fn.executable("rg") then
					return { "rg", "--files", "--color", "never", "-g", "!.git" }
				elseif 1 == vim.fn.executable("fd") then
					return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
				elseif 1 == vim.fn.executable("fdfind") then
					return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
				elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
					return { "find", ".", "-type", "f" }
				elseif 1 == vim.fn.executable("where") then
					return { "where", "/r", ".", "*" }
				end
			end

			return {
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					-- open files in the first window that is an actual file.
					-- use the current window if no other window is available.
					get_selection_window = function()
						local wins = vim.api.nvim_list_wins()
						table.insert(wins, 1, vim.api.nvim_get_current_win())
						for _, win in ipairs(wins) do
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].buftype == "" then
								return win
							end
						end
						return 0
					end,
					mappings = {
						i = {
							["<a-i>"] = find_files_no_ignore,
							["<a-h>"] = find_files_with_hidden,
							["<C-Down>"] = actions.cycle_history_next,
							["<C-Up>"] = actions.cycle_history_prev,
							["<C-f>"] = actions.preview_scrolling_down,
							["<C-b>"] = actions.preview_scrolling_up,
						},
						n = {
							["q"] = actions.close,
						},
					},
				},
				pickers = {
					find_files = {
						find_command = find_command,
						hidden = true,
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				indicator = {
					style = "underline",
				},
			}
		end,
		keys = {
			-- Helpers
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "[F]uzzy [h]elp",
			},
			{
				"<leader>fk",
				"<cmd>Telescope keymaps<cr>",
				desc = "[F]uzzy [k]eymaps",
			},
			{
				"<leader>ft",
				"<cmd>Telescope builtin<cr>",
				desc = "[F]uzzy [t]elescope",
			},

			-- Buffer
			{
				"<leader>fb",
				"<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
				desc = "[F]uzzy [b]uffers",
			},
			{
				"<leader>f/",
				"<cmd>Telescope current_buffer_fuzzy_find<cr>",
				desc = "[F]uzzy find current [b]uffer",
			},

			-- Files
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "[F]uzzy [f]iles",
			},
			{
				"<leader>fF",
				function()
					require("telescope.builtin").find_files({
						cwd = require("telescope.utils").buffer_dir(),
					})
				end,
				desc = "[F]uzzy [F]iles (current dir)",
			},
			{
				"<leader>f.",
				":Telescope oldfiles<cr>",
				desc = "[F]uzzy [.] Oldfiles",
			},

			-- Grep
			{
				"<leader>fg",
				"<cmd>Telescope live_grep<cr>",
				desc = "[F]uzzy with [g]rep",
			},
			{
				"<leader>fG",
				function()
					require("telescope.builtin").live_grep({
						cwd = require("telescope.utils").buffer_dir(),
					})
				end,
				"<cmd>Telescope live_grep<cr>",
				desc = "[F]uzzy with [G]rep (current dir)",
			},
			{
				"<leader>fw",
				"<cmd>Telescope grep_string<cr>",
				desc = "[F]uzzy current [w]ord",
			},

			-- Git
			{ "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "[g]it [f]iles" },
			{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "[g]it [c]ommits" },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "[g]it [s]tatus" },

			-- Diagnostics
			{
				"<leader>fd",
				":Telescope diagnostics bufnr=0<cr>",
				desc = "[F]uzzy [d]iagnostics (document)",
			},
			{
				"<leader>fD",
				":Telescope diagnostics<cr>",
				desc = "[F]uzzy [D]iagnostics (workspace)",
			},

			-- Jump
			{
				"<leader>fj",
				":Telescope jumplist<cr>",
				desc = "[F]uzzy [j]umplist",
			},
			{
				"<leader>fm",
				":Telescope marks<cr>",
				desc = "[F]uzzy [m]arks",
			},
			{
				"<leader>fq",
				":Telescope quickfix<cr>",
				desc = "[F]uzzy [q]uickfix",
			},
			{
				"<leader>fl",
				":Telescope loclist<cr>",
				desc = "[F]uzzy [l]oclist",
			},

      -- Quick access
			{
				"<leader>fc",
				function()
					require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "[F]uzzy Neovim [c]onfigs",
			},
			{
				"<leader>fn",
				function()
					require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/notes") })
				end,
				desc = "[F]uzzy [n]otes",
			},


			-- Misc
			{
				"<leader>fr",
				":Telescope resume<cr>",
				desc = "[F]uzzy [r]esume",
			},
			{
				"<leader>fv",
				":Telescope vim_options<cr>",
				desc = "[F]uzzy [v]im options",
			},
			{
				"<leader>f:",
				":Telescope command_history<cr>",
				desc = "[F]uzzy [:] Command history",
			},
			{
				"<leader>fC",
				function()
					require("telescope.builtin").colorscheme({ enable_preview = true })
				end,
				desc = "[F]uzzy [C]olorscheme",
			},
		},
		config = function(_, opts)
			require("telescope").setup(opts)

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
		end,
	},
	{
		"neovim/nvim-lspconfig",
		cond = function()
			return MNvim.config.picker == "telescope"
		end,
		opts = function()
			if MNvim.config.picker ~= "telescope" then
				return
			end

			local Keys = MNvim.get_lsp_keys()
			vim.list_extend(Keys, {
				{
					"gd",
					function()
						require("telescope.builtin").lsp_definitions({ reuse_win = true })
					end,
					desc = "[g]oto [d]efinition",
					has = "definition",
				},
				{
					"gr",
					"<cmd>Telescope lsp_references<cr>",
					desc = "[g]oto [r]eferences",
					nowait = true,
				},
				{
					"gi",
					function()
						require("telescope.builtin").lsp_implementations({ reuse_win = true })
					end,
					desc = "[g]oto [i]mplementation",
				},
				{
					"gt",
					function()
						require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
					end,
					desc = "[g]oto [t]ype definition",
				},
			})
		end,
	},
}
