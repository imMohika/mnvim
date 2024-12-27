return {
	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		lazy = true,
		cmd = { "ConformInfo" },
		keys = {
			{
				"<c-f>",
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				mode = { "n", "v" },
				desc = "[F]ormat buffer",
			},
			{
				"<leader>F",
				function()
					require("conform").format({
						formatters = { "injected" },
						timeout_ms = 3000,
					})
				end,
				mode = { "n", "v" },
				desc = "[F]ormat injected",
			},
		},
		---@type conform.setupOpts
		opts = {
			notify_on_error = true,
			default_format_opts = {
				timeout_ms = 3000,
				async = true,
				quiet = false,
				lsp_format = "fallback",
			},
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
			formatters = {
				injected = { options = { ignore_errors = true } },
			},
		},
	},
}
