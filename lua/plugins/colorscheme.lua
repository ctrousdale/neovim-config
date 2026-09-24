return {
	"EdenEast/nightfox.nvim",
	lazy = false,
	priority = 1000,
	build = false,
	config = function()
		vim.opt.background = "dark"
		require("nightfox").setup({
			options = {
				transparent = true,
			},
		})
		vim.cmd.colorscheme("carbonfox")

		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
	end,
}
