require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {},
	formatters = {
		markdown = { "prettierd", "prettier" },
	},
	linters = {
		markdown = { "markdownlint" },
	},
}

return language
