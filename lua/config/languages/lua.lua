require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		lua_ls = {
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		},
	},
	formatters = {
		lua = { "stylua" },
	},
	linters = {},
}

return language
