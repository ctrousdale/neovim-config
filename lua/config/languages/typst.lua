require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		tinymist = {},
	},
	formatters = {
		typst = { "typstyle" },
	},
	linters = {},
}

return language
