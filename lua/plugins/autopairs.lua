local M = {}

M.settings = {}

function M.setup()
	require("nvim-autopairs").setup(M.settings)
end

return M
