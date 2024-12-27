local colorschemes = {
	{ "Shatur/neovim-ayu", "ayu", "ayu-dark" },
	{ "arturgoms/moonbow.nvim", "moonbow" },
}

local ret = nil

if not ret then
	local tmp = {}
	for _, scheme in ipairs(colorschemes) do
		local pkg = scheme[1]
		local name = scheme[2]
		local theme = scheme[3] or name
		local enabled = MNvim.config.colorscheme == name
		table.insert(tmp, {
			pkg,
			lazy = not enabled,
			priority = enabled and 1000 or 50,
			init = function()
				if enabled then
					vim.cmd.colorscheme(theme)
				end
			end,
		})
	end
	ret = tmp
end

return ret
