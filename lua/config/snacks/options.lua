local M = {}

function M.get()
	return {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = {
			enabled = true,
			hidden = true,
			ignored = true,
		},
		indent = { enabled = true },
		input = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		picker = {
			enabled = true,
			hidden = true,
			ignored = true,
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = {
			notification = {
				wo = { wrap = true },
			},
		},
		terminal = {
			enabled = true,
			win = {
				position = "float",
				border = "rounded",
				style = "float",
			},
		},
	}
end

return M
