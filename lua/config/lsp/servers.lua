local M = {}

function M.get()
	return require("config.languages").lsp
end

function M.setup(capabilities)
	vim.lsp.config("*", { capabilities = capabilities })

	for server_name, server_config in pairs(M.get()) do
		vim.lsp.config(server_name, server_config)
		vim.lsp.enable(server_name)
	end
end

return M
