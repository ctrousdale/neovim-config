require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		roslyn_ls = {},
	},
	formatters = {
		cs = { "csharpier" },
	},
	linters = {},
}

return language
