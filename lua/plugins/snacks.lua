return {
	{
		"folke/snacks.nvim",
		priority = 900,
		lazy = false,
		---@type snacks.Config
		opts = {
			animate = {
				enabled = true,
			},
			dashboard = {
				enabled = true,
				-- width = 80,
				pane_gap = 2,
				sections = {
					{
						section = "terminal",
						cmd = "chafa ~/.config/wall.png --format symbols --symbols vhalf -s 60x17 -c full; sleep 0.1sec",
						height = 17,
						padding = 1,
					},
					{
						pane = 2,
						{ section = "keys", gap = 1, padding = 1 },
						{ section = "startup" },
					},
				},
			},
			indent = { enabled = false },
			input = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
				style = "compact",
			},
			quickfile = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = false },
			words = { enabled = true },
			styles = {
				notification = {
					wo = { wrap = true } -- Wrap notifications
				},
			},
      lazygit = {
        configure = true,
      }
		},
		keys = function()
			local Snacks = require("snacks")
			return {
				-- Scratch
				{
					"<leader>.",
					function()
						Snacks.scratch()
					end,
					desc = "Toggle Scratch Buffer",
				},
				{
					"<leader>S",
					function()
						Snacks.scratch.select()
					end,
					desc = "Select Scratch Buffer",
				},

				-- Notification
				{
					"<leader>n",
					function()
						Snacks.notifier.show_history()
					end,
					desc = "Notification History",
				},
				{
					"<leader>un",
					function()
						Snacks.notifier.hide()
					end,
					desc = "Dismiss All Notifications",
				},

				-- Git
				{
					"<leader>gb",
					function()
						Snacks.git.blame_line()
					end,
					desc = "Git Blame Line",
				},
				{
					"<leader>gB",
					function()
						Snacks.gitbrowse()
					end,
					desc = "Git Browse",
					mode = { "n", "v" },
				},
				{
					"<leader>gf",
					function()
						Snacks.lazygit.log_file()
					end,
					desc = "Lazygit Current File History",
				},
				{
					"<leader>gg",
					function()
						Snacks.lazygit()
					end,
					desc = "Lazygit",
				},
				{
					"<leader>gl",
					function()
						Snacks.lazygit.log()
					end,
					desc = "Lazygit Log (cwd)",
				},

				-- Terminal
				{
					"<c-/>",
					function()
						Snacks.terminal()
					end,
					desc = "Toggle Terminal",
				},
				{
					"<c-_>",
					function()
						Snacks.terminal()
					end,
					desc = "which_key_ignore",
				},

				-- Jump
				{
					"]]",
					function()
						Snacks.words.jump(vim.v.count1)
					end,
					desc = "Next Reference",
					mode = { "n", "t" },
				},
				{
					"[[",
					function()
						Snacks.words.jump(-vim.v.count1)
					end,
					desc = "Prev Reference",
					mode = { "n", "t" },
				},

				-- Misc
				{
					"<leader>bd",
					function()
						Snacks.bufdelete()
					end,
					desc = "Delete Buffer",
				},
				{
					"<leader>N",
					desc = "Neovim News",
					function()
						Snacks.win({
							file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
							width = 0.6,
							height = 0.6,
							wo = {
								spell = false,
								wrap = false,
								signcolumn = "yes",
								statuscolumn = " ",
								conceallevel = 3,
							},
						})
					end,
				},
			}
		end,
		init = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					-- Setup some globals for debugging (lazy-loaded)
					_G.dd = function(...)
						Snacks.debug.inspect(...)
					end
					_G.bt = function()
						Snacks.debug.backtrace()
					end
					vim.print = _G.dd -- Override print to use snacks for `:=` command

					-- Create some toggle mappings
					Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
					Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
					Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
					Snacks.toggle.diagnostics():map("<leader>ud")
					Snacks.toggle.line_number():map("<leader>ul")
					Snacks.toggle
						.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
						:map("<leader>uc")
					Snacks.toggle.treesitter():map("<leader>uT")
					Snacks.toggle
						.option("background", { off = "light", on = "dark", name = "Dark Background" })
						:map("<leader>ub")
					Snacks.toggle.inlay_hints():map("<leader>uh")
					Snacks.toggle.indent():map("<leader>ug")
					Snacks.toggle.dim():map("<leader>uD")
				end,
			})
		end,
	},
}
