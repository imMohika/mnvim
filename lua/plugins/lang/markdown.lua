MNvim.on_very_lazy(function()
	vim.filetype.add({
		extension = { mds = "markdown.mdx" },
	})
end)

return {
	-- Preview
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		ft = { "markdown" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			code = {
				width = "block",
				right_pad = 1,
			},
		},
    config = function (_, opts)
      require("render-markdown").setup(opts)

      require("snacks").toggle({
        name = "Render Markdown",
        get = function ()
          return require("render-markdown.state").enabled
        end,
        set = function (enabled)
          local render = require("render-markdown")
          if enabled then
            render.enable()
          else
            render.disable()
          end
        end
      }):map("<leader>um")
    end
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
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
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
