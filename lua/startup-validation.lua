local M = {}

function M.validate_nvim_install()
	local v = vim.version()
	if v.major < 0 or (v.major == 0 and v.minor < 11) then
		vim.notify("Neovim >= 0.11 is required!", vim.log.levels.ERROR)
	end
	if vim.fn.executable("lazygit") == 0 then
		vim.notify("lazygit is not installed or not in PATH!", vim.log.levels.ERROR)
	end
end

return M
