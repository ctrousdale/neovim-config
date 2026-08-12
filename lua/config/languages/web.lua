require("config.languages.types")

---@type LanguageConfig
local language = {
	lsp = {
		tailwindcss = {
			filetypes = {
				"css",
				"html",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			},
		},
	},
	formatters = {
		css = { "prettierd", "prettier" },
		html = { "prettierd", "prettier" },
		javascript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		json = { "prettierd", "prettier" },
		jsonc = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
	},
	linters = {},
}

return language
