return {
	{
		"nvim-neorg/neorg",
		version = "*",
		ft = "norg",
		cmd = "Neorg",
		lazy = true,
		keys = {
			{
				"<leader>fN",
				function()
					local dirman = require("neorg").modules.get_module("core.dirman")
					local workspace = dirman.get_current_workspace()
					local path = tostring(workspace[2])

					if MNvim.config.picker == "telescope" then
						require("telescope.builtin").find_files({ cwd = path })
					end
				end,
				desc = "[F]uzzy [N]eorg",
			},
		},
		opts = {
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/notes",
						},
						default_workspace = "notes",
					},
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "norg" } },
	},
}
