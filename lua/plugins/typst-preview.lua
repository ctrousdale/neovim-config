return {
	"chomosuke/typst-preview.nvim",
	ft = "typst",
	version = "1.*",
	keys = {
		{
			"<leader>cp",
			"<cmd>TypstPreviewToggle<cr>",
			ft = "typst",
			desc = "Toggle Typst [P]review",
		},
	},
	opts = {
		dependencies_bin = {
			tinymist = "tinymist",
			websocat = "websocat",
		},
	},
}
