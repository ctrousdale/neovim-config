local M = {}

local function picker(method, ...)
	local args = { ... }
	return function()
		local up = table.unpack or unpack
		Snacks.picker[method](up(args))
	end
end

function M.get()
	return {
		{
			"<leader><space>",
			picker("smart"),
			desc = "Smart Find Files",
		},
		{
			"<leader>,",
			picker("buffers"),
			desc = "Buffers",
		},
		{
			"<leader>/",
			picker("grep"),
			desc = "Grep",
		},
		{
			"<leader>:",
			picker("command_history"),
			desc = "Command History",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
		{
			"<leader>fb",
			picker("buffers"),
			desc = "Buffers",
		},
		{
			"<leader>fc",
			picker("files", { cwd = vim.fn.stdpath("config") }),
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			picker("files"),
			desc = "Find Files",
		},
		{
			"<leader>fg",
			picker("git_files"),
			desc = "Find Git Files",
		},
		{
			"<leader>fp",
			picker("projects"),
			desc = "Projects",
		},
		{
			"<leader>fr",
			picker("recent"),
			desc = "Recent",
		},
		{
			"<leader>gb",
			picker("git_branches"),
			desc = "Git Branches",
		},
		{
			"<leader>gl",
			picker("git_log"),
			desc = "Git Log",
		},
		{
			"<leader>gL",
			picker("git_log_line"),
			desc = "Git Log Line",
		},
		{
			"<leader>gs",
			picker("git_status"),
			desc = "Git Status",
		},
		{
			"<leader>gS",
			picker("git_stash"),
			desc = "Git Stash",
		},
		{
			"<leader>gd",
			picker("git_diff"),
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>gf",
			picker("git_log_file"),
			desc = "Git Log File",
		},
		{
			"<leader>sB",
			picker("grep_buffers"),
			desc = "Grep Open Buffers",
		},
		{
			"<leader>sg",
			picker("grep"),
			desc = "Grep",
		},
		{
			"<leader>sw",
			picker("grep_word"),
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
		{
			'<leader>s"',
			picker("registers"),
			desc = "Registers",
		},
		{
			"<leader>s/",
			picker("search_history"),
			desc = "Search History",
		},
		{
			"<leader>sa",
			picker("autocmds"),
			desc = "Autocmds",
		},
		{
			"<leader>sc",
			picker("command_history"),
			desc = "Command History",
		},
		{
			"<leader>sC",
			picker("commands"),
			desc = "Commands",
		},
		{
			"<leader>sd",
			picker("diagnostics"),
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			picker("diagnostics_buffer"),
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>sh",
			picker("help"),
			desc = "Help Pages",
		},
		{
			"<leader>sH",
			picker("highlights"),
			desc = "Highlights",
		},
		{
			"<leader>si",
			picker("icons"),
			desc = "Icons",
		},
		{
			"<leader>sj",
			picker("jumps"),
			desc = "Jumps",
		},
		{
			"<leader>sk",
			picker("keymaps"),
			desc = "Keymaps",
		},
		{
			"<leader>sl",
			picker("loclist"),
			desc = "Location List",
		},
		{
			"<leader>sm",
			picker("marks"),
			desc = "Marks",
		},
		{
			"<leader>sM",
			picker("man"),
			desc = "Man Pages",
		},
		{
			"<leader>sp",
			picker("lazy"),
			desc = "Search for Plugin Spec",
		},
		{
			"<leader>sq",
			picker("qflist"),
			desc = "Quickfix List",
		},
		{
			"<leader>sR",
			picker("resume"),
			desc = "Resume",
		},
		{
			"<leader>su",
			picker("undo"),
			desc = "Undo History",
		},
		{
			"<leader>uC",
			picker("colorschemes"),
			desc = "Colorschemes",
		},
		{
			"gd",
			picker("lsp_definitions"),
			desc = "Goto Definition",
		},
		{
			"gD",
			picker("lsp_declarations"),
			desc = "Goto Declaration",
		},
		{
			"gr",
			picker("lsp_references"),
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			picker("lsp_implementations"),
			desc = "Goto Implementation",
		},
		{
			"gy",
			picker("lsp_type_definitions"),
			desc = "Goto T[y]pe Definition",
		},
		{
			"<leader>ss",
			picker("lsp_symbols"),
			desc = "LSP Symbols",
		},
		{
			"<leader>sS",
			picker("lsp_workspace_symbols"),
			desc = "LSP Workspace Symbols",
		},
		{
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "Toggle Zen Mode",
		},
		{
			"<leader>Z",
			function()
				Snacks.zen.zoom()
			end,
			desc = "Toggle Zoom",
		},
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete Buffer",
		},
		{
			"<leader>cR",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
		},
		{
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			mode = { "n", "v" },
			desc = "Git Browse",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"<c-/>",
			function()
				Snacks.terminal()
			end,
			desc = "Toggle Terminal",
		},
		{
			"<c-_>",
			function()
				Snacks.terminal()
			end,
			desc = "which_key_ignore",
		},
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			mode = { "n", "t" },
			desc = "Next Reference",
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			mode = { "n", "t" },
			desc = "Prev Reference",
		},
		{
			"<leader>N",
			function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.6,
					height = 0.6,
					wo = {
						spell = false,
						wrap = false,
						signcolumn = "yes",
						statuscolumn = " ",
						conceallevel = 3,
					},
				})
			end,
			desc = "Neovim News",
		},
	}
end

return M
