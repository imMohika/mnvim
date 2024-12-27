local diag_icons = {
	Error = "",
	Warn = "",
	Info = "",
	Hint = "",
}

local function get_diagnostic_label(buf)
	local label = {}
	for severity, icon in pairs(diag_icons) do
		local n = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
		if n > 0 then
			table.insert(label, { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity })
		end
	end

	if #label > 0 then
		table.insert(label, { "| " })
	end

	return label
end

return {
	-- Tabs
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		},
		opts = function()
			local snacks = require("snacks")
			return {
				options = {
					close_command = function(n)
						snacks.bufdelete(n)
					end,
					right_mouse_command = function(n)
						snacks.bufdelete(n)
					end,
					diagnostics = "nvim_lsp",
					always_show_bufferline = true,
					diagnostics_indicator = function(_, _, diag)
						if diag.error then
							return diag_icons.Error .. diag.error
						end
						return " "
					end,
					---@param opts bufferline.IconFetcherOpts
					get_element_icon = function(opts)
						-- local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(opts.filetype, { default = false })
						-- return icon, hl
						return require("mini.icons").get("filetype", opts.filetype)
					end,
				},
			}
		end,
		config = function(_, opts)
			require("bufferline").setup(opts)
			-- Fix bufferline when restoring a session
			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
				callback = function()
					vim.schedule(function()
						pcall(nvim_bufferline)
					end)
				end,
			})
		end,
	},
	{
		"b0o/incline.nvim",
		event = "VeryLazy",
		opts = {
			hide = {
				cursorline = true,
			},
			render = function(props)
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
				if filename == "" then
					filename = "No Name"
				end
				local modified = vim.api.nvim_get_option_value("modified", { buf = props.buf }) and "bold,italic"
					or "None"
				local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)

				local diagnostics = get_diagnostic_label(props.buf)

				local label = {}
				table.insert(label, { (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" })
				table.insert(label, { vim.bo[props.buf].modified and " " or "", guifg = "#d19a66" })
				table.insert(label, { filename, gui = vim.bo[props.buf].modified and "bold,italic" or "bold" })
				if not props.focused then
					label["group"] = "BufferInactive"
				end

				return {
					{ "", guifg = "#0e0e0e" },
					{
						{ diagnostics },
						{ label, gui = modified },
						guibg = "#0e0e0e",
					},
					{ "", guifg = "#0e0e0e" },
				}
			end,
		},
		-- config = function()
		-- 	require("incline").setup()
		-- end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "LazyFile",
		opts = { mode = "cursor", max_lines = 3 },
	},
}
