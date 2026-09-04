require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		basedpyright = {},
	},
	formatters = {
		python = { "ruff_format" },
	},
	linters = {
		python = { "ruff" },
	},
}

return language
