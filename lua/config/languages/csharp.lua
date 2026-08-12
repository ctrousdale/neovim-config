require("config.languages.types")

local function get_roslyn_log_dir()
	return vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs")
end

local function get_roslyn_cmd()
	if vim.fn.executable("Microsoft.CodeAnalysis.LanguageServer") == 1 then
		return {
			"Microsoft.CodeAnalysis.LanguageServer",
			"--logLevel",
			"Information",
			"--extensionLogDirectory",
			get_roslyn_log_dir(),
			"--stdio",
		}
	end

	return {
		"roslyn-language-server",
		"--logLevel",
		"Information",
		"--extensionLogDirectory",
		get_roslyn_log_dir(),
		"--stdio",
	}
end

---@type LanguageConfig
local language = {
	lsp = {
		roslyn_ls = {
			cmd = get_roslyn_cmd(),
		},
	},
	formatters = {
		cs = { "csharpier" },
	},
	linters = {},
}

return language
