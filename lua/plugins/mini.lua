return {
	{
		"echasnovski/mini.nvim",
		version = false,
		lazy = false,
		priority = 900,
		config = function()
			local icons = require("mini.icons")
			icons.setup({})
			-- Because Telescope
			icons.mock_nvim_web_devicons()

			require("mini.ai").setup({
				n_lines = 500,
			})

			require("mini.surround").setup({})

			require("mini.pairs").setup({})

			require("mini.cursorword").setup({})

			require("mini.bracketed").setup({})

			-- Switch to gitsigns
			-- require("mini.diff").setup({})

			require("mini.move").setup({})

			require("mini.jump").setup({})

			-- Using bufferline instead
			-- require("mini.tabline").setup({})

			require("mini.trailspace").setup({})

			-- Indent
			-- require("mini.indentscope").setup({
			-- 	symbol = "│",
			-- 	options = { try_as_border = true },
			-- })

			-- Animate
			-- local animate = require("mini.animate")
			-- animate.setup({
			-- 	resize = {
			-- 		timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
			-- 	},
			-- 	scroll = {
			-- 		timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
			-- 		subscroll = animate.gen_subscroll.equal({
			-- 			predicate = function(total_scroll)
			-- 				return total_scroll > 1
			-- 			end,
			-- 		}),
			-- 	},
			-- })

			-- Commnet
			require("mini.comment").setup({
				options = {
					custom_commentstring = function()
						return require("ts_context_commentstring.internal").calculate_commentstring()
							or vim.bo.commentstring
					end,
				},
			})

			-- Statusline
			-- TODO: switch to lualine maybe
			require("mini.statusline").setup({})
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = true })
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- Files
			-- Switched to oil
			-- local files = require("mini.files")
			-- files.setup({})
			-- vim.keymap.set("n", "<space>\\", function()
			-- 	local _ = files.close() or files.open()
			-- end, {})

			-- hilight patterns
			local hipatterns = require("mini.hipatterns")
			local goalGroup = hipatterns.compute_hex_color_group("#ffffff", "bg")
			hipatterns.setup({
				highlighters = {
					-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE', 'GOAL'
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
					goal = { pattern = "%f[%w]()GOAL()%f[%W]", group = goalGroup },

					-- Highlight hex color strings (`#rrggbb`) using that color
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
		end,
	},
}
