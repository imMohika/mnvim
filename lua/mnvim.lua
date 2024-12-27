---@class MNvim
local M = {}

---@class MNvimOptions
local defaults = {
	---@type  "ayu"|"moonbow"
	colorscheme = "moonbow",
	---@type "telescope"|"fzf"
	picker = "telescope",
}

local options

---@param opts MNvimOptions
function M.with_config(opts)
	options = vim.tbl_deep_extend("force", defaults, opts or {})
	M.config = options
	return M
end

---@param name string
M.get_plugin = function(name)
	return require("lazy.core.config").spec.plugins[name]
end

---@param name string
M.opts = function(name)
	local plugin = M.get_plugin(name)
	if not plugin then
		return {}
	end
	local Plugin = require("lazy.core.plugin")
	return Plugin.values(plugin, "opts", false)
end

---@param put_above boolean
M.put_empty_line = function(put_above)
	-- This has a typical workflow for enabling dot-repeat:
	-- - On first call it sets `operatorfunc`, caches data, and calls
	--   `operatorfunc` on current cursor position.
	-- - On second call it performs task: puts `v:count1` empty lines
	--   above/below current line.
	if type(put_above) == "boolean" then
		vim.o.operatorfunc = "v:lua.MNvim.put_empty_line"
		M.cache_empty_line = { put_above = put_above }
		return "g@l"
	end

	local target_line = vim.fn.line(".") - (M.cache_empty_line.put_above and 1 or 0)
	vim.fn.append(target_line, vim.fn["repeat"]({ "" }, vim.v.count1))
end

---@param fn fun()
function M.on_very_lazy(fn)
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = function()
			fn()
		end,
	})
end

function M.foldexpr()
	local buf = vim.api.nvim_get_current_buf()
	if vim.b[buf].ts_folds == nil then
		-- as long as we don't have a filetype, don't bother
		-- checking if treesitter is available (it won't)
		if vim.bo[buf].filetype == "" then
			return "0"
		end
		if vim.bo[buf].filetype:find("dashboard") then
			vim.b[buf].ts_folds = false
		else
			vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
		end
	end
	return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

function M.formatexpr()
	if require("lazy.core.config").spec.plugins["conform.nvim"] then
		return require("conform").formatexpr()
	end
	return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

---@type LazyKeysLspSpec[]|nil
local lsp_keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string|string[], cond?:fun():boolean}
---@alias LazyKeysLsp LazyKeys|{has?:string|string[], cond?:fun():boolean}

---@return LazyKeysLspSpec[]
function M.get_lsp_keys()
	if lsp_keys then
		return lsp_keys
	end

	lsp_keys = {
		{ "gd", vim.lsp.buf.definition, desc = "[g]oto [d]efinition", has = "definition" },
		{ "gD", vim.lsp.buf.declaration, desc = "[g]oto [D]eclaration" },
		{ "gr", vim.lsp.buf.references, desc = "[g]oto [r]eferences", nowait = true },
		{ "gi", vim.lsp.buf.implementation, desc = "[g]oto [i]mplementation" },
		{ "gt", vim.lsp.buf.type_definition, desc = "[g]oto [t]ype definition" },
		{
			"K",
			function()
				return vim.lsp.buf.hover()
			end,
			desc = "LSP Hover",
		},
		{
			"gK",
			function()
				return vim.lsp.buf.signature_help()
			end,
			desc = "LSP Signature Help",
			has = "signatureHelp",
		},
		{
			"<c-k>",
			function()
				return vim.lsp.buf.signature_help()
			end,
			mode = "i",
			desc = "LSP Signature Help",
			has = "signatureHelp",
		},
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "[c]ode [a]ction", mode = { "n", "v" }, has = "codeAction" },
		{ "<leader>cl", vim.lsp.codelens.run, desc = "run [c]ode[l]ens", mode = { "n", "v" }, has = "codeLens" },
		{
			"<leader>cL",
			vim.lsp.codelens.refresh,
			desc = "Refresh & Display [C]ode[L]ens",
			mode = { "n" },
			has = "codeLens",
		},
		{ "<leader>cr", vim.lsp.buf.rename, desc = "[R]ename", has = "rename" },
	}
	return lsp_keys
end

---@param method string|string[]
function M.lsp_has(buffer, method)
	if type(method) == "table" then
		for _, m in ipairs(method) do
			if M.lsp_has(buffer, m) then
				return true
			end
		end
		return false
	end
	method = method:find("/") and method or "textDocument/" .. method
	local clients = vim.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		if client.supports_method(method) then
			return true
		end
	end
	return false
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return vim.deepcopy(defaults)[key]
		end
		---@cast options MNvimOptions
		return options[key]
	end,
})

return M
