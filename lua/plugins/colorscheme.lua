return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	build = false,
	config = function()
		vim.opt.background = "dark"
		require("kanagawa").setup({
			transparent = true,
			theme = "dragon",
			background = {
				dark = "dragon",
				light = "lotus",
			},
		})
		vim.cmd.colorscheme("kanagawa-dragon")

		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
	end,
}
