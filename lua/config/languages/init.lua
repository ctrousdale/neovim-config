local language_modules = {}
local languages_dir = vim.fn.stdpath("config") .. "/lua/config/languages"

for name, type in vim.fs.dir(languages_dir) do
	local module_name = name:match("^(.*)%.lua$")
	-- Home Manager deploys this directory as symlinks, which vim.fs.dir reports as
	-- "link" rather than "file".
	if (type == "file" or type == "link") and module_name and module_name ~= "init" and module_name ~= "types" then
		table.insert(language_modules, "config.languages." .. module_name)
	end
end

table.sort(language_modules)

---@type LanguageConfig
local languages = {
	lsp = {},
	formatters = {},
	linters = {},
}

for _, module_name in ipairs(language_modules) do
	local language = require(module_name)
	for name, config in pairs(language.lsp) do
		languages.lsp[name] = config
	end
	for filetype, formatters in pairs(language.formatters) do
		languages.formatters[filetype] = formatters
	end
	for filetype, linters in pairs(language.linters) do
		languages.linters[filetype] = linters
	end
end

return languages
