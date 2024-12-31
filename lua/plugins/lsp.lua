---@return LazyKeysLsp[]
local resolve = function(buffer)
	local Keys = require("lazy.core.handler.keys")
	if not Keys.resolve then
		return {}
	end
	local spec = vim.tbl_extend("force", {}, MNvim.get_lsp_keys())
	local clients = vim.lsp.get_clients({ bufnr = buffer })
	local opts = MNvim.opts("nvim-lspconfig")
	for _, client in ipairs(clients) do
		local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
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
		cmd = "LazyDev",
		opts = {
			library = {
				-- { path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason.nvim",
			{ "williamboman/mason-lspconfig.nvim", config = function() end },

			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		---@type PluginLspOpts
		opts = {
			inlay_hints = {
				enabled = true,
			},
			codelens = {
				enabled = true,
			},
			-- global capabilities
			capabilities = {
				workspace = {
					fileOperations = {
						didRename = true,
						willRename = true,
					},
				},
			},
			servers = {
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
			},
		},
		---@param opts PluginLspOpts
		config = function(_, opts)
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

			local servers = opts.servers
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				require("blink.cmp").get_lsp_capabilities() or {},
				opts.capabilities or {}
			)

			local function setup_server(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})
				if server_opts.enabled == false then
					return
				end

				require("lspconfig")[server].setup(server_opts)
			end

			local all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			local ensure_installed = {} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					if server_opts.enabled ~= false then
						if not vim.tbl_contains(all_mslp_servers, server) then
							setup_server(server)
						else
							ensure_installed[#ensure_installed + 1] = server
						end
					end
				end
			end

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_deep_extend(
					"force",
					ensure_installed,
					MNvim.opts("mason-lspconfig.nvim").ensure_installed or {}
				),
				handlers = { setup_server },
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = {
				"stylua",
			},
		},
		---@param opts MasonSettings | {ensure_installed: string[]}
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					-- trigger FileType event to possibly load this newly installed LSP server
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)

			mr.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end)
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
