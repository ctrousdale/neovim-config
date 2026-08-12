return {
	"zk-org/zk-nvim",
	ft = "markdown",
	cmd = {
		"ZkBacklinks",
		"ZkIndex",
		"ZkInsertLink",
		"ZkLinks",
		"ZkMatch",
		"ZkNew",
		"ZkNotes",
		"ZkTags",
	},
	opts = {
		picker = "snacks_picker",
	},
	config = function(_, opts)
		require("zk").setup(opts)
	end,
	keys = {
		{
			"<leader>nn",
			function()
				local title = vim.fn.input("Title: ")
				vim.cmd("ZkNew { title = " .. vim.inspect(title) .. " }")
			end,
			desc = "[N]otes [N]ew",
		},
		{
			"<leader>nd",
			"<Cmd>ZkNew { dir = 'journal/daily' }<CR>",
			desc = "[N]otes [D]aily",
		},
		{ "<leader>no", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", desc = "[N]otes [O]pen" },
		{
			"<leader>nf",
			function()
				local query = vim.fn.input("Search: ")
				vim.cmd("ZkNotes { sort = { 'modified' }, match = { " .. vim.inspect(query) .. " } }")
			end,
			desc = "[N]otes [F]ind",
		},
		{ "<leader>nt", "<Cmd>ZkTags<CR>", desc = "[N]otes [T]ags" },
		{ "<leader>nb", "<Cmd>ZkBacklinks<CR>", desc = "[N]otes [B]acklinks" },
		{ "<leader>nl", "<Cmd>ZkLinks<CR>", desc = "[N]otes [L]inks" },
		{ "<leader>ni", "<Cmd>ZkInsertLink<CR>", mode = "v", desc = "[N]otes [I]nsert link" },
	},
}
