local M = {}

local function get_roslyn_cmd()
	if vim.fn.executable("Microsoft.CodeAnalysis.LanguageServer") == 1 then
		return { "Microsoft.CodeAnalysis.LanguageServer", "--stdio" }
	end

	return { "roslyn-language-server", "--stdio" }
end

local function find_roslyn_root(fname)
	local path = type(fname) == "number" and vim.api.nvim_buf_get_name(fname) or fname
	local start = vim.fs.dirname(path)
	local project_file = vim.fs.find(function(name)
		return name:match("%.slnx?$") or name:match("%.csproj$")
	end, { path = start, upward = true })[1]

	return project_file and vim.fs.dirname(project_file) or nil
end

function M.get(capabilities)
	return {
		bashls = {},
		tailwindcss = {},
		roslyn_ls = {
			cmd = get_roslyn_cmd(),
			filetypes = { "cs" },
			capabilities = capabilities,
			root_dir = find_roslyn_root,
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
