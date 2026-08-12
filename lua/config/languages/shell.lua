require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		bashls = {},
	},
	formatters = {
		sh = { "beautysh" },
	},
	linters = {
		sh = { "shellcheck" },
	},
}

return language
