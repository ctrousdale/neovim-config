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
			function()
				local notebook_path = require("zk.util").resolve_notebook_path(0)
				local notebook_root = notebook_path and require("zk.util").notebook_root(notebook_path)
				if not notebook_root then
					vim.notify("No zk notebook found", vim.log.levels.ERROR)
					return
				end

				local daily_dir = vim.fs.joinpath(notebook_root, "daily")
				local daily_note = vim.fs.joinpath(daily_dir, vim.fn.strftime("%Y-%m-%d") .. ".md")
				vim.fn.mkdir(daily_dir, "p")
				if vim.fn.filereadable(daily_note) == 0 then
					vim.fn.writefile({}, daily_note)
				end
				vim.cmd.edit(vim.fn.fnameescape(daily_note))
			end,
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
