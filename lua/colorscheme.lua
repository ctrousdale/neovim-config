local M = {}

M.settings = {
	transparent_background = true,
}

function M.apply()
	require("tokyodark").setup(M.settings)
	vim.cmd.colorscheme("tokyodark")
end

return M
