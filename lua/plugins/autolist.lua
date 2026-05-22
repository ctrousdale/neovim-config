local filetypes = { "markdown", "text", "tex", "plaintex", "norg" }

local function set_autolist_keymaps(bufnr)
	local opts = function(desc)
		return { buffer = bufnr, desc = desc }
	end

	vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<CR>", opts("Autolist New Bullet"))
	vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<CR>", opts("Autolist New Bullet Below"))
	vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<CR>", opts("Autolist New Bullet Above"))
	vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<CR>", opts("Autolist Indent"))
	vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<CR>", opts("Autolist Outdent"))
	vim.keymap.set("n", "<leader>cx", "<cmd>AutolistToggleCheckbox<CR>", opts("Toggle Checkbox"))
	vim.keymap.set("n", "<leader>cL", "<cmd>AutolistRecalculate<CR>", opts("Recalculate List"))
end

return {
	"gaoDean/autolist.nvim",
	ft = filetypes,
	opts = {},
	config = function(_, opts)
		require("autolist").setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("autolist-keymaps", { clear = true }),
			pattern = filetypes,
			callback = function(event)
				set_autolist_keymaps(event.buf)
			end,
		})

		set_autolist_keymaps(vim.api.nvim_get_current_buf())
	end,
}
