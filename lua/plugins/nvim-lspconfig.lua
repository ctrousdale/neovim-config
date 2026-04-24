local lsp_attach = require("config.lsp.attach")
local lsp_diagnostics = require("config.lsp.diagnostics")
local lsp_servers = require("config.lsp.servers")

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", opts = {} },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} },
		"saghen/blink.cmp",
	},
	config = function()
		lsp_attach.setup()
		lsp_diagnostics.setup()

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		lsp_servers.setup(capabilities)
	end,
}
