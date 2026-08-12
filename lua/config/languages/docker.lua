require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		docker_compose_language_service = {},
		docker_language_server = {},
	},
	formatters = {},
	linters = {},
}

return language
