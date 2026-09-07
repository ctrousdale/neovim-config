return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	cmd = "Neogen",
	keys = {
		{
			"<leader>cn",
			function()
				require("neogen").generate()
			end,
			desc = "Code Annotation",
		},
		{
			"<leader>cN",
			function()
				require("neogen").generate({ type = "file" })
			end,
			desc = "File Annotation",
		},
		{
			"<leader>cC",
			function()
				require("neogen").generate({ type = "class" })
			end,
			desc = "Class Annotation",
		},
		{
			"<leader>cT",
			function()
				require("neogen").generate({ type = "type" })
			end,
			desc = "Type Annotation",
		},
	},
	opts = {},
}
