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

local function report(messages, strict)
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

	if all_ok then
		vim.notify("Smoke checks passed", vim.log.levels.INFO)
	else
		vim.notify("Smoke checks completed with warnings", vim.log.levels.WARN)
	end

	return all_ok
end

return M
