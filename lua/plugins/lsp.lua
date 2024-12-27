-- See `:help lspconfig-all` for a list of all the pre-configured LSPs
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
				-- diagnostics = { disable = { 'missing-fields' } },
			},
		},
	},
}

---@return LazyKeysLsp[]
local resolve = function(buffer)
	local Keys = require("lazy.core.handler.keys")
	if not Keys.resolve then
		return {}
	end
	local spec = vim.tbl_extend("force", {}, MNvim.get_lsp_keys())
	local clients = vim.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		local maps = servers[client.name] and servers[client.name].keys or {}
		vim.list_extend(spec, maps)
	end
	return Keys.resolve(spec)
end

local register_keys = function(buffer)
	local Keys = require("lazy.core.handler.keys")
	local keymaps = resolve(buffer)

	for _, keys in pairs(keymaps) do
		local keyHas = not keys.has or MNvim.lsp_has(buffer, keys.has)
		local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

		if keyHas and cond then
			local opts = Keys.opts(keys)
			opts.cond = nil
			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = buffer
			vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
		end
	end
end

---@type LazySpec
return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local buffer = args.buf ---@type number
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end

					register_keys(buffer)
				end,
			})

			for server, config in pairs(servers) do
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				require("lspconfig")[server].setup(config)
			end
			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = require("blink.cmp").get_lsp_capabilities(server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		opts = {
			preset = "simple",
			options = {
				-- If multiple diagnostics are under the cursor, display all of them.
				multiple_diag_under_cursor = true,
				-- Enable diagnostic message on all lines.
				multilines = true,
				-- Show all diagnostics on the cursor line.
				show_all_diags_on_cursorline = true,
			},
		},
		config = function(_, opts)
			vim.diagnostic.config({ virtual_text = false })
			require("tiny-inline-diagnostic").setup(opts)
		end,
	},
}
