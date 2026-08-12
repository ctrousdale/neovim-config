local M = {}

local protected_mappings = {
	"n|<leader>/",
	"n|<leader>n",
	"n|<leader>sb",
	"n|<leader>sd",
	"n|<leader>sg",
	"n|<leader>sh",
	"n|<leader>ss",
	"n|gd",
	"n|gr",
	"n|<C-h>",
	"n|<C-j>",
	"n|<C-k>",
	"n|<C-l>",
}

local protected_lookup = {}
for _, key in ipairs(protected_mappings) do
	protected_lookup[key] = true
end

local keymap_owner_modules = {
	"plugins.snacks",
	"plugins.vim-tmux-navigator",
}

local report

local function normalize_modes(mode)
	if mode == nil then
		return { "n" }
	end
	if type(mode) == "string" then
		return { mode }
	end
	if type(mode) == "table" then
		return mode
	end
	return {}
end

local function format_key(mode, lhs)
	return mode .. "|" .. lhs
end

local function add_owner(store, mode, lhs, owner)
	local key = format_key(mode, lhs)
	if not protected_lookup[key] then
		return
	end

	if not store[key] then
		store[key] = {
			owners = {},
			owner_counts = {},
		}
	end

	if not store[key].owner_counts[owner] then
		table.insert(store[key].owners, owner)
		store[key].owner_counts[owner] = 0
	end

	store[key].owner_counts[owner] = store[key].owner_counts[owner] + 1
end

local function load_owner_spec(owner_module)
	local module_path = package.searchpath(owner_module, package.path)
	if module_path then
		local ok, spec = pcall(dofile, module_path)
		if ok then
			return spec
		end
	end

	local ok, spec = pcall(require, owner_module)
	if ok then
		return spec
	end

	return nil
end

local function module_exists(module_name)
	return package.searchpath(module_name, package.path) ~= nil
end

local function append_error(errors, message)
	table.insert(errors, "Language tooling contract violation: " .. message)
end

local function assert_exact_set(actual, expected, label, errors)
	for name in pairs(expected) do
		if actual[name] == nil then
			append_error(errors, ("%s is missing %s"):format(label, name))
		end
	end

	for name in pairs(actual) do
		if expected[name] == nil then
			append_error(errors, ("%s includes unexpected %s"):format(label, name))
		end
	end
end

local function display_value(value)
	if type(value) == "string" then
		return string.format("%q", value)
	end
	return tostring(value)
end

function M.compare_ordered_formatters(expected, actual, filetype)
	if type(actual) ~= "table" then
		return false, ("formatter list for %s must be a table, found %s"):format(filetype, type(actual))
	end

	if #expected ~= #actual then
		return false,
			("formatter list for %s has %d entries; expected %d (%s)"):format(
				filetype,
				#actual,
				#expected,
				table.concat(expected, ", ")
			)
	end

	for index, formatter in ipairs(expected) do
		if actual[index] ~= formatter then
			return false,
				("formatter list for %s differs at position %d: expected %s, found %s"):format(
					filetype,
					index,
					formatter,
					display_value(actual[index])
				)
		end
	end

	return true
end

local function assert_formatters(errors)
	local expected = {
		lua = { "stylua" },
		javascript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
		json = { "prettierd", "prettier" },
		jsonc = { "prettierd", "prettier" },
		html = { "prettierd", "prettier" },
		css = { "prettierd", "prettier" },
		sh = { "beautysh" },
		markdown = { "prettierd", "prettier" },
		nix = { "alejandra" },
		cs = { "csharpier" },
	}
	local conform = require("plugins.conform")
	local options = conform.opts
	local languages = require("config.languages")

	assert_exact_set(options.formatters_by_ft, expected, "formatters_by_ft", errors)
	assert_exact_set(options.formatters_by_ft, languages.formatters, "Conform registry formatter parity", errors)
	for filetype, expected_formatters in pairs(expected) do
		local ok, message = M.compare_ordered_formatters(
			expected_formatters,
			options.formatters_by_ft[filetype],
			filetype
		)
		if not ok then
			append_error(errors, message)
		end
	end

	local reversed_ok, reversed_message = M.compare_ordered_formatters(
		{ "prettierd", "prettier" },
		{ "prettier", "prettierd" },
		"formatter-order-fixture"
	)
	if reversed_ok or not (reversed_message or ""):match("position 1: expected prettierd, found \"prettier\"") then
		append_error(errors, "ordered formatter comparison must reject a reversed fixture with its differing position")
	end

	local original_filetype = vim.bo.filetype
	vim.bo.filetype = "c"
	if options.format_on_save(0) ~= nil then
		append_error(errors, "format_on_save must be disabled for c")
	end
	vim.bo.filetype = "cpp"
	if options.format_on_save(0) ~= nil then
		append_error(errors, "format_on_save must be disabled for cpp")
	end
	vim.bo.filetype = "lua"
	local lua_format_on_save = options.format_on_save(0)
	if lua_format_on_save == nil or lua_format_on_save.timeout_ms ~= 3000 or lua_format_on_save.lsp_format ~= "fallback" then
		append_error(errors, "format_on_save must retain the 3000ms LSP fallback policy for enabled filetypes")
	end
	vim.bo.filetype = original_filetype
end

local function assert_lsp_servers(errors)
	local servers = require("config.lsp.servers").get()
	local expected_servers = {
		bashls = true,
		docker_language_server = true,
		docker_compose_language_service = true,
		tailwindcss = true,
		roslyn_ls = true,
		nil_ls = true,
		lua_ls = true,
	}

	assert_exact_set(servers, expected_servers, "LSP server set", errors)
	for _, server_name in ipairs({ "bashls", "docker_language_server", "docker_compose_language_service", "tailwindcss", "nil_ls" }) do
		if next(servers[server_name] or {}) ~= nil then
			append_error(errors, ("%s must use its empty default configuration"):format(server_name))
		end
	end

	local roslyn = servers.roslyn_ls or {}
	if roslyn.capabilities ~= nil then
		append_error(errors, "roslyn_ls declarations must not include runtime capabilities")
	end
	local expected_roslyn_executable = vim.fn.executable("Microsoft.CodeAnalysis.LanguageServer") == 1
			and "Microsoft.CodeAnalysis.LanguageServer"
			or "roslyn-language-server"
	if
		roslyn.cmd == nil
		or roslyn.cmd[1] ~= expected_roslyn_executable
		or roslyn.cmd[2] ~= "--logLevel"
		or roslyn.cmd[3] ~= "Information"
		or roslyn.cmd[4] ~= "--extensionLogDirectory"
		or roslyn.cmd[5] ~= vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs")
		or roslyn.cmd[6] ~= "--stdio"
	then
		append_error(errors, "roslyn_ls must retain its executable fallback and logging command")
	end

	local lua_settings = servers.lua_ls and servers.lua_ls.settings
	if lua_settings == nil or lua_settings.Lua == nil or lua_settings.Lua.completion.callSnippet ~= "Replace" then
		append_error(errors, "lua_ls must set Lua.completion.callSnippet to Replace")
	end

	local registry_servers = require("config.languages").lsp
	if servers ~= registry_servers then
		append_error(errors, "LSP server declarations must come directly from config.languages")
	end
end

local function assert_lsp_setup_branch(errors, modern)
	local lsp_servers = require("config.lsp.servers")
	local source_servers = require("config.languages").lsp
	local source_snapshot = vim.deepcopy(source_servers)
	local capabilities = { smoke_capability = true }
	local configured = {}
	local enabled = {}
	local legacy_setups = {}
	local original_lsp_config = vim.lsp.config
	local original_lsp_enable = vim.lsp.enable
	local original_mason_tool_installer = package.loaded["mason-tool-installer"]
	local original_mason_lspconfig = package.loaded["mason-lspconfig"]
	local original_lspconfig = package.loaded.lspconfig
	local ok, message = xpcall(function()
		package.loaded["mason-tool-installer"] = { setup = function() end }
		package.loaded["mason-lspconfig"] = { setup = function() end }
		package.loaded.lspconfig = setmetatable({}, {
			__index = function(_, server_name)
				return {
					setup = function(config)
						legacy_setups[server_name] = legacy_setups[server_name] or {}
						table.insert(legacy_setups[server_name], vim.deepcopy(config))
					end,
				}
			end,
		})

		if modern then
			vim.lsp.config = function(server_name, config)
				configured[server_name] = configured[server_name] or {}
				table.insert(configured[server_name], vim.deepcopy(config))
			end
			vim.lsp.enable = function(server_name)
				enabled[server_name] = (enabled[server_name] or 0) + 1
			end
		else
			vim.lsp.config = nil
			vim.lsp.enable = nil
		end

		lsp_servers.setup(capabilities)
	end, debug.traceback)
	vim.lsp.config = original_lsp_config
	vim.lsp.enable = original_lsp_enable
	package.loaded["mason-tool-installer"] = original_mason_tool_installer
	package.loaded["mason-lspconfig"] = original_mason_lspconfig
	package.loaded.lspconfig = original_lspconfig

	local branch_name = modern and "modern" or "legacy"
	if not ok then
		append_error(errors, ("%s LSP setup branch could not be characterized: %s"):format(branch_name, message))
		return
	end
	if not vim.deep_equal(source_servers, source_snapshot) then
		append_error(errors, ("%s LSP setup must not mutate registry declarations"):format(branch_name))
	end

	local calls = modern and configured or legacy_setups
	local expected_servers = {
		bashls = true,
		docker_language_server = true,
		docker_compose_language_service = true,
		tailwindcss = true,
		roslyn_ls = true,
		nil_ls = true,
		lua_ls = true,
	}
	assert_exact_set(calls, expected_servers, branch_name .. " LSP setup server set", errors)
	for server_name in pairs(expected_servers) do
		if #(calls[server_name] or {}) ~= 1 then
			append_error(errors, ("%s LSP setup must configure %s exactly once"):format(branch_name, server_name))
		else
			local config = calls[server_name][1]
			if not vim.deep_equal(config.capabilities, capabilities) then
				append_error(errors, ("%s LSP setup must inject capabilities for %s"):format(branch_name, server_name))
			end
			config.capabilities = nil
			if not vim.deep_equal(config, source_servers[server_name]) then
				append_error(errors, ("%s LSP setup must preserve options for %s"):format(branch_name, server_name))
			end
		end
		if modern and enabled[server_name] ~= 1 then
			append_error(errors, ("modern LSP setup must enable %s exactly once"):format(server_name))
		end
	end
	if not modern and next(configured) ~= nil then
		append_error(errors, "legacy LSP setup must not call vim.lsp.config")
	end
end

local function assert_lsp_setup_compatibility(errors)
	assert_lsp_setup_branch(errors, true)
	assert_lsp_setup_branch(errors, false)
end

local function assert_lint_policy(errors)
	local lint_spec = require("plugins.lint")[1]
	local expected_events = { "BufReadPre", "BufNewFile" }
	local events_ok, events_message = M.compare_ordered_formatters(expected_events, lint_spec.event, "lint plugin events")
	if not events_ok then
		append_error(errors, events_message)
	end

	local original_lint = package.loaded.lint
	local original_create_augroup = vim.api.nvim_create_augroup
	local original_create_autocmd = vim.api.nvim_create_autocmd
	local original_opt_local = vim.opt_local
	local unrelated_linters = { "fixturelint" }
	local mock_lint = { linters_by_ft = { fixture = unrelated_linters }, runs = 0 }
	local captured_autocmd
	local modifiable = true
	local ok, message = xpcall(function()
		package.loaded.lint = mock_lint
		mock_lint.try_lint = function()
			mock_lint.runs = mock_lint.runs + 1
		end
		vim.api.nvim_create_augroup = function(name, options)
			if name ~= "lint" or options.clear ~= true then
				append_error(errors, "lint must create a cleared lint augroup")
			end
			return 1
		end
		vim.api.nvim_create_autocmd = function(events, options)
			captured_autocmd = { events = events, options = options }
		end
		vim.opt_local = { modifiable = { get = function() return modifiable end } }

		lint_spec.config()
		if captured_autocmd then
			captured_autocmd.options.callback()
			modifiable = false
			captured_autocmd.options.callback()
		end
	end, debug.traceback)
	vim.opt_local = original_opt_local
	vim.api.nvim_create_augroup = original_create_augroup
	vim.api.nvim_create_autocmd = original_create_autocmd
	package.loaded.lint = original_lint

	if not ok then
		append_error(errors, "lint configuration could not be characterized: " .. message)
		return
	end

	local markdown_ok, markdown_message = M.compare_ordered_formatters({ "markdownlint" }, mock_lint.linters_by_ft.markdown, "markdown linters")
	local shell_ok, shell_message = M.compare_ordered_formatters({ "shellcheck" }, mock_lint.linters_by_ft.sh, "shell linters")
	local languages = require("config.languages")
	if not markdown_ok then
		append_error(errors, markdown_message)
	end
	if not shell_ok then
		append_error(errors, shell_message)
	end
	for filetype, expected_linters in pairs(languages.linters) do
		local linters_ok, linters_message = M.compare_ordered_formatters(
			expected_linters,
			mock_lint.linters_by_ft[filetype],
			filetype .. " registry linters"
		)
		if not linters_ok then
			append_error(errors, linters_message)
		end
	end
	if mock_lint.linters_by_ft.fixture ~= unrelated_linters then
		append_error(errors, "lint configuration must preserve unrelated linter entries")
	end
	if captured_autocmd == nil then
		append_error(errors, "lint must register an autocmd")
		return
	end
	local triggers_ok, triggers_message = M.compare_ordered_formatters(
		{ "BufWritePost", "InsertLeave" },
		captured_autocmd.events,
		"lint triggers"
	)
	if not triggers_ok then
		append_error(errors, triggers_message)
	end

	if mock_lint.runs ~= 1 then
		append_error(errors, "lint callback must run only for modifiable buffers")
	end
end

local function assert_docker_filetypes(errors)
	local function match_docker_filetype(filename, lines)
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(bufnr, filename)
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
		local filetype = vim.filetype.match({ buf = bufnr })
		vim.api.nvim_buf_delete(bufnr, { force = true })
		return filetype
	end

	local expected = {
		["compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["docker-compose.yml"] = "yaml.docker-compose",
	}

	for filename, filetype in pairs(expected) do
		if vim.filetype.match({ filename = filename }) ~= filetype then
			append_error(errors, ("%s must resolve to %s"):format(filename, filetype))
		end
	end

	for _, filename in ipairs({ ".dockerfile", "service.dockerfile" }) do
		if match_docker_filetype(filename, {}) ~= "dockerfile" then
			append_error(errors, ("%s must resolve to dockerfile when it is not Compose content"):format(filename))
		end
	end
	if match_docker_filetype(".dockerfile", { "services:" }) ~= "yaml.docker-compose" then
		append_error(errors, ".dockerfile with Compose content must resolve to yaml.docker-compose")
	end
end

function M.assert_language_tooling_contract(opts)
	opts = opts or {}
	local strict = opts.strict ~= false
	local violations = {}

	assert_lsp_servers(violations)
	assert_lsp_setup_compatibility(violations)
	assert_formatters(violations)
	assert_lint_policy(violations)
	assert_docker_filetypes(violations)

	return report(violations, strict)
end

local function collect_keymap_owners()
	local owners = {}
	for _, owner_module in ipairs(keymap_owner_modules) do
		local spec = load_owner_spec(owner_module)
		if type(spec) == "table" and type(spec.keys) == "table" then
			for _, map in ipairs(spec.keys) do
				if type(map) == "table" and type(map[1]) == "string" then
					for _, mode in ipairs(normalize_modes(map.mode)) do
						add_owner(owners, mode, map[1], owner_module)
					end
				end
			end
		end
	end

	return owners
end

report = function(messages, strict)
	if #messages == 0 then
		return true
	end

	if strict then
		error(table.concat(messages, "\n"))
	end

	for _, message in ipairs(messages) do
		vim.notify(message, vim.log.levels.WARN)
	end
	return false
end

function M.assert_keymap_policy(opts)
	opts = opts or {}
	local strict = opts.strict ~= false
	local owners = collect_keymap_owners()
	local violations = {}

	for _, key in ipairs(protected_mappings) do
		local owner_entry = owners[key]
		if owner_entry then
			if #owner_entry.owners > 1 then
				table.insert(
					violations,
					("Keymap policy violation for %s: protected mapping has multiple owners (%s)"):format(
						key,
						table.concat(owner_entry.owners, ", ")
					)
				)
			end

			for owner, count in pairs(owner_entry.owner_counts) do
				if count > 1 then
					table.insert(
						violations,
						("Keymap policy violation for %s: owner %s defines it %d times"):format(key, owner, count)
					)
				end
			end
		end
	end

	if report(violations, strict) then
		return true
	end

	return false
end

function M.assert_provider_policy(opts)
	opts = opts or {}
	local strict = opts.strict ~= false
	local violations = {}
	local warnings = {}
	local required_owner_modules = {
		"plugins.snacks",
		"plugins.mini",
	}
	local forbidden_owner_modules = {
		"plugins.telescope",
		"plugins.lualine",
	}
	local disabled_providers = {
		loaded_node_provider = "node",
		loaded_ruby_provider = "ruby",
		loaded_perl_provider = "perl",
	}

	for _, owner_module in ipairs(required_owner_modules) do
		if not module_exists(owner_module) then
			table.insert(
				violations,
				("Provider policy violation: required owner module is missing (%s)"):format(owner_module)
			)
		end
	end

	for _, owner_module in ipairs(forbidden_owner_modules) do
		if module_exists(owner_module) then
			table.insert(
				violations,
				("Provider policy violation: forbidden owner module is present (%s)"):format(owner_module)
			)
		end
	end

	for global_name, provider_name in pairs(disabled_providers) do
		local value = vim.g[global_name]
		if value ~= 0 then
			table.insert(
				violations,
				("Provider policy violation: vim.g.%s must be 0 (found %s)"):format(global_name, vim.inspect(value))
			)
		end

		if vim.fn.executable(provider_name) == 0 then
			table.insert(warnings, ("Optional executable missing: %s (non-fatal)"):format(provider_name))
		end
	end

	if vim.fn.executable("python3") == 0 then
		table.insert(warnings, "Optional executable missing: python3 (non-fatal unless python provider is required)")
	end

	for _, message in ipairs(warnings) do
		vim.notify(message, vim.log.levels.WARN)
	end

	if report(violations, strict) then
		return true
	end

	return false
end

function M.run()
	local all_ok = true

	if not M.assert_keymap_policy({ strict = false }) then
		all_ok = false
	end

	if not M.assert_provider_policy({ strict = false }) then
		all_ok = false
	end

	if not M.assert_language_tooling_contract({ strict = false }) then
		all_ok = false
	end

	if all_ok then
		vim.notify("Smoke checks passed", vim.log.levels.INFO)
	else
		vim.notify("Smoke checks completed with warnings", vim.log.levels.WARN)
	end

	return all_ok
end

return M
