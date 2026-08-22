require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		nixd = {},
	},
	formatters = {
		nix = { "alejandra" },
	},
	linters = {},
}

return language
