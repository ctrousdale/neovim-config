local M = {}

function M.get(capabilities)
	return {
		bashls = {},
		tailwindcss = {},
		omnisharp = {
			cmd = { "OmniSharp" },
			filetypes = { "cs", "vb" },
			capabilities = capabilities,
		},
		nil_ls = {},
		lua_ls = {
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		},
	}
end

local function setup_mason()
	require("mason-tool-installer").setup({})
	require("mason-lspconfig").setup({
		ensure_installed = {},
		automatic_installation = false,
		automatic_enable = false,
	})
end

function M.setup(capabilities)
	local servers = M.get(capabilities)

	setup_mason()

	for server_name, server in pairs(servers) do
		local server_config = vim.deepcopy(server)
		server_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})

		if vim.lsp.config and vim.lsp.enable then
			vim.lsp.config(server_name, server_config)
			vim.lsp.enable(server_name)
		else
			require("lspconfig")[server_name].setup(server_config)
		end
	end
end

return M
