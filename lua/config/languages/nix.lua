require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		nil_ls = {},
	},
	formatters = {
		nix = { "alejandra" },
	},
	linters = {},
}

return language
