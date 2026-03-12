return {
	"https://codeberg.org/esensar/nvim-dev-container",
	dependencies = "nvim-treesitter/nvim-treesitter",
	lazy = false,
	config = function()
		require("devcontainer").setup({})
	end,
}
