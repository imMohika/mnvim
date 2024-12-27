local function augroup(name)
	return vim.api.nvim_create_augroup("mnvim" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_on_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto cd:
-- Running `nvim` in home directory (~) cds to nvim config directory
-- Running `nvim` in other directories (not ~) works normally
-- Running `nvim [dir]` cds to dir (sets cwd to dir)
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup("auto_cd"),
	pattern = "*",
	callback = function()
		local args = vim.fn.argv()
		local cwd = vim.fn.getcwd()
		local target

		-- Auto switch to Neovim config when no directory is passed and we're in home dir
		if #args == 0 and cwd == vim.fn.expand("~") then
			local config_dir = vim.fn.stdpath("config")
			if type(config_dir) == "table" then
				config_dir = config_dir[1]
			end
			args = { config_dir }
		end

		for _, arg in ipairs(type(args) == "table" and args or {}) do
			local dir = arg
      -- When starting nvim oil changes the value of `vim.fn.getcwd()`
      -- to it's custom path (oil:///c/....).
			if vim.startswith(dir, "oil://") then
				dir = dir:gsub("^oil:///", "/"):gsub("^oil://", "")
				dir = dir:gsub("^/([a-zA-Z])/", "%1:/")
			else
				dir = vim.fn.fnamemodify(dir, ":p:h")
			end

			if vim.fn.isdirectory(dir) then
				target = dir
				break
			end
		end

		if target then
			vim.cmd("cd " .. vim.fn.fnameescape(target))
			vim.notify("Changed directory to: " .. target)
		end
	end,
})

---- From lazyvim
-- Auto mkdir when saving a file
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_mkdir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})
