local M = {}

function M.get()
	return require("config.languages").lsp
end

function M.setup(capabilities)
	local servers = M.get()

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
