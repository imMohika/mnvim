MNvim.on_very_lazy(function()
	vim.filetype.add({
		extension = { mdx = "markdown.mdx" },
	})
end)

return {
	-- Preview
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
		ft = { "markdown" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			code = {
				width = "block",
				right_pad = 1,
			},
			heading = {
				position = "inline",
				width = "block",
			},
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)

			require("snacks")
				.toggle({
					name = "Render Markdown",
					get = function()
						return require("render-markdown.state").enabled
					end,
					set = function(enabled)
						local render = require("render-markdown")
						if enabled then
							render.enable()
						else
							render.disable()
						end
					end,
				})
				:map("<leader>um")
		end,
	},

	-- Tools
	{
		"tadmccorkle/markdown.nvim",
		ft = { "markdown" },
		opts = {
			link = {
				paste = {
					enable = true, -- whether to convert URLs to links on paste
				},
			},
			on_attach = function(bufnr)
				local map = function(lhs, rhs, mode, opts)
					mode = mode or "n"
					opts = vim.tbl_deep_extend("force", opts or {}, { buffer = bufnr })
					vim.keymap.set(mode, lhs, rhs, opts)
				end
				map("<M-l><M-o>", "<Cmd>MDListItemBelow<CR>", { "n", "i" })
				map("<M-l><M-o>", "<Cmd>MDListItemBelow<CR>", { "n", "i" })
				map("<M-L><M-O>", "<Cmd>MDListItemAbove<CR>", { "n", "i" })
				map("<M-c>", "<Cmd>MDTaskToggle<CR>")
				map("<M-c>", ":MDTaskToggle<CR>", "x")
				map("<cr>", "<Plug>(markdown_follow_link)")

				local function toggle(key)
					return "<Esc>gv<Cmd>lua require'markdown.inline'" .. ".toggle_emphasis_visual'" .. key .. "'<CR>"
				end

				map("<C-b>", toggle("b"), "x")
				map("<C-i>", toggle("i"), "x")
			end,
		},
	},

	-- Cmp
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			sources = {
				default = { "markdown" },
				providers = {
					markdown = {
						name = "RenderMarkdown",
						module = "render-markdown.integ.blink",
						fallbacks = { "lsp" },
					},
				},
			},
		},
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters = {
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				["markdownlint-cli2"] = {
					-- condition = function(_, ctx)
					-- 	local diag = vim.tbl_filter(function(d)
					-- 		return d.source == "markdownlint"
					-- 	end, vim.diagnostic.get(ctx.buf))
					-- 	return #diag > 0
					-- end,
				},
			},
			formatters_by_ft = {
				["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "markdownlint-cli2", "markdown-toc" } },
	},

	-- Lint
	{
		"mfussenegger/nvim-lint",
		optional = true,
		opts = {
			linters_by_ft = {
				markdown = { "markdownlint-cli2" },
			},
		},
	},

	-- Lsp
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				marksman = {},
			},
		},
	},
}
