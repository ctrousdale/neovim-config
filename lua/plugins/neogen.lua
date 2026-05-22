return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	cmd = "Neogen",
	keys = {
		{
			"<leader>ca",
			function()
				require("neogen").generate()
			end,
			desc = "Code Annotation",
		},
		{
			"<leader>cA",
			function()
				require("neogen").generate({ type = "file" })
			end,
			desc = "File Annotation",
		},
		{
			"<leader>cc",
			function()
				require("neogen").generate({ type = "class" })
			end,
			desc = "Class Annotation",
		},
		{
			"<leader>ct",
			function()
				require("neogen").generate({ type = "type" })
			end,
			desc = "Type Annotation",
		},
	},
	opts = {},
}
