local detail = false

local function parse_output(proc)
	local result = proc:wait()
	local ret = {}
	if result.code == 0 then
		for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
			-- Remove trailing slash
			line = line:gsub("/$", "")
			ret[line] = true
		end
	end
	return ret
end

local function new_git_status()
	return setmetatable({}, {
		__index = function(self, key)
			local ignore_proc = vim.system(
				{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
				{
					cwd = key,
					text = true,
				}
			)
			local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
				cwd = key,
				text = true,
			})
			local ret = {
				ignored = parse_output(ignore_proc),
				tracked = parse_output(tracked_proc),
			}

			rawset(self, key, ret)
			return ret
		end,
	})
end
local git_status = new_git_status()

function _G.get_oil_winbar()
	local dir = require("oil").get_current_dir()
	if dir then
		return vim.fn.fnamemodify(dir, ":~")
	else
		-- If there is no current directory (e.g. over ssh), just show the buffer name
		return vim.api.nvim_buf_get_name(0)
	end
end

---@type LazySpec
return {
	{
		"stevearc/oil.nvim",
		dependencies = { { "echasnovski/mini.nvim" } },
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			win_options = {
				wrap = true,
				cursorcolumn = true,
				winbar = "%!v:lua.get_oil_winbar()",
				list = true,
			},
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name, bufnr)
					local dir = require("oil").get_current_dir(bufnr)
					local is_dotfile = vim.startswith(name, ".") and name ~= ".."
					-- if no local directory (e.g. for ssh connections), just hide dotfiles
					if not dir then
						return is_dotfile
					end
					-- dotfiles are considered hidden unless tracked
					if is_dotfile then
						return not git_status[dir].tracked[name]
					else
						-- Check if file is gitignored
						return git_status[dir].ignored[name]
					end
				end,
				case_insensitive = true,
			},
			keymaps = {
				["gd"] = {
					desc = "Toggle file detail view",
					callback = function()
						detail = not detail
						if detail then
							require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
						else
							require("oil").set_columns({ "icon" })
						end
					end,
				},
				["h"] = { "actions.parent", mode = "n" },
				["l"] = { "actions.select", mode = "n" },
			},
		},
		---@param opts oil.SetupOpts
		config = function(_, opts)
			local refresh = require("oil.actions").refresh
			local orig_refresh = refresh.callback
			refresh.callback = function(...)
				git_status = new_git_status()
				orig_refresh(...)
			end
			require("oil").setup(opts)

			vim.keymap.set({ "n", "v" }, "<leader>\\", "<cmd>Oil<cr>", { desc = "Open Oil" })
		end,
	},
}
