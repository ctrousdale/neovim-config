local M = {}

local function is_supported_nvim()
	local v = vim.version()
	return v.major > 0 or (v.major == 0 and v.minor >= 11)
end

function M.validate_nvim_install()
	if not is_supported_nvim() then
		vim.notify("Neovim >= 0.11 is required!", vim.log.levels.ERROR)
	end
	if vim.fn.executable("lazygit") == 0 then
		vim.notify("lazygit is not installed or not in PATH (optional)", vim.log.levels.WARN)
	end
end

return M
