local M = {}

local function normalize_modes(mode)
	if mode == nil then
		return { "n" }
	end
	if type(mode) == "string" then
		return { mode }
	end
	return mode
end

local function config_root()
	local source = debug.getinfo(1, "S").source:sub(2)
	return vim.fn.fnamemodify(source, ":p:h:h")
end

local function plugin_specs()
	local specs = {}
	local plugins_dir = vim.fs.joinpath(config_root(), "lua", "plugins")

	for name, type in vim.fs.dir(plugins_dir) do
		local module_name = name:match("^(.*)%.lua$")
		if (type == "file" or type == "link") and module_name then
			local spec = dofile(vim.fs.joinpath(plugins_dir, name))
			if type(spec) ~= "table" then
				error(("plugin spec %s must return a table"):format(module_name))
			end

			if type(spec[1]) == "string" then
				table.insert(specs, { name = module_name, spec = spec })
			else
				for _, nested_spec in ipairs(spec) do
					table.insert(specs, { name = module_name, spec = nested_spec })
				end
			end
		end
	end

	return specs
end

local function assert_plugin_keymaps()
	local owners = {}

	for _, entry in ipairs(plugin_specs()) do
		for _, map in ipairs(entry.spec.keys or {}) do
			if type(map) ~= "table" or type(map[1]) ~= "string" then
				error(("plugin spec %s has an invalid keymap"):format(entry.name))
			end

			for _, mode in ipairs(normalize_modes(map.mode)) do
				local key = mode .. "|" .. map[1]
				owners[key] = owners[key] or {}
				table.insert(owners[key], entry.name)
			end
		end
	end

	for key, mapping_owners in pairs(owners) do
		if #mapping_owners > 1 then
			error(("duplicate plugin keymap %s: %s"):format(key, table.concat(mapping_owners, ", ")))
		end

		local mode, lhs = key:match("^(.)|(.*)$")
		if next(vim.fn.maparg(lhs, mode, false, true)) == nil then
			error(("plugin keymap is not active: %s"):format(key))
		end
	end
end

local function assert_language_registry()
	local languages = require("config.languages")

	for _, section in ipairs({ "lsp", "formatters", "linters" }) do
		if type(languages[section]) ~= "table" then
			error(("language registry section %s must be a table"):format(section))
		end
	end

	for server_name, config in pairs(languages.lsp) do
		if type(server_name) ~= "string" or type(config) ~= "table" then
			error("language registry contains an invalid LSP declaration")
		end

		local runtime_config = vim.lsp.config[server_name]
		if type(runtime_config) ~= "table" or type(runtime_config.capabilities) ~= "table" then
			error(("LSP server %s is not enabled with completion capabilities"):format(server_name))
		end
	end

	for _, section in ipairs({ "formatters", "linters" }) do
		for filetype, tools in pairs(languages[section]) do
			if type(filetype) ~= "string" or type(tools) ~= "table" then
				error(("language registry contains an invalid %s declaration"):format(section))
			end
			for _, tool in ipairs(tools) do
				if type(tool) ~= "string" then
					error(("language registry contains a non-string %s tool"):format(section))
				end
			end
		end
	end
end

local function assert_format_policy()
	local conform = require("plugins.conform")
	local format_on_save = conform.opts.format_on_save
	local select_nix_formatters = conform.opts.formatters_by_ft.nix
	local generated_buffer = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_name(generated_buffer, "/tmp/nixos/system/test/hardware-configuration.nix")
	vim.bo[generated_buffer].filetype = "nix"

	if type(select_nix_formatters) ~= "function" or #select_nix_formatters(generated_buffer) ~= 0 then
		error("generated hardware configurations must not have a Nix formatter")
	end
	if format_on_save(generated_buffer) ~= nil then
		error("generated hardware configurations must not be formatted on save")
	end

	vim.api.nvim_buf_delete(generated_buffer, { force = true })
end

local function assert_docker_filetypes()
	local function filetype_for(filename, lines)
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(bufnr, filename)
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
		local filetype = vim.filetype.match({ buf = bufnr })
		vim.api.nvim_buf_delete(bufnr, { force = true })
		return filetype
	end

	for _, filename in ipairs({ "compose.yaml", "compose.yml", "docker-compose.yaml", "docker-compose.yml" }) do
		if vim.filetype.match({ filename = filename }) ~= "yaml.docker-compose" then
			error(("%s must resolve to yaml.docker-compose"):format(filename))
		end
	end

	if filetype_for(".dockerfile", {}) ~= "dockerfile" then
		error("ordinary .dockerfile files must resolve to dockerfile")
	end
	if filetype_for(".dockerfile", { "services:" }) ~= "yaml.docker-compose" then
		error("Compose content in .dockerfile must resolve to yaml.docker-compose")
	end
end

function M.run()
	local errors = {}
	for _, check in ipairs({
		assert_plugin_keymaps,
		assert_language_registry,
		assert_format_policy,
		assert_docker_filetypes,
	}) do
		local ok, err = xpcall(check, debug.traceback)
		if not ok then
			table.insert(errors, err)
		end
	end

	if #errors > 0 then
		vim.notify(table.concat(errors, "\n\n"), vim.log.levels.WARN)
		return false
	end

	vim.notify("Smoke checks passed", vim.log.levels.INFO)
	return true
end

return M
