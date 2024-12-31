return {
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				lazy = true,
				dependencies = {
					{
						"rafamadriz/friendly-snippets",
						config = function()
							local vscode = require("luasnip.loaders.from_vscode")
							vscode.lazy_load()
							vscode.lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
						end,
					},
				},
				opts = {
					history = true,
				},
			},
		},
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "enter" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			completion = {
				keyword = {
					range = "full",
				},
				list = {
					selection = "auto_insert",
				},
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = {
					enabled = true,
				},
				menu = {
					auto_show = true,
					draw = {
						treesitter = { "lsp" },
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
									return kind_icon
								end,
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
						},
					},
				},
			},
			signature = {
				enabled = true,
			},
			snippets = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
				active = function(filter)
					if filter and filter.direction then
						return require("luasnip").jumpable(filter.direction)
					end
					return require("luasnip").in_snippet()
				end,
				jump = function(direction)
					require("luasnip").jump(direction)
				end,
			},
			sources = {
				default = { "lazydev", "lsp", "path", "luasnip", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- show at a higher priority than lsp
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
