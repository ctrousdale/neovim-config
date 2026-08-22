return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
		--  - ci'  - [C]hange [I]nside [']quote
		require("mini.ai").setup({ n_lines = 500 })

		-- Save named, global Neovim sessions outside project directories. This
		-- complements tmux-resurrect: tmux restores panes and working directories,
		-- while these sessions restore Neovim buffers, tabs, and splits.
		local sessions = require("mini.sessions")
		sessions.setup({
			autoread = false,
			autowrite = true,
			file = "",
		})

		vim.keymap.set("n", "<leader>ss", function()
			sessions.select("read")
		end, { desc = "[S]ession: [S]elect/load" })
		vim.keymap.set("n", "<leader>sw", function()
			local name = vim.fn.input("Session name: ")
			if name ~= "" then
				sessions.write(name, { force = true })
			end
		end, { desc = "[S]ession: [W]rite" })
		vim.keymap.set("n", "<leader>sd", function()
			sessions.select("delete")
		end, { desc = "[S]ession: [D]elete" })

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
		--       require('mini.surround').setup({
		--         mappings = {
		--          add = 'gs'
		--        }
		--      })

		-- Simple and easy statusline.
		--  You could remove this setup call if you don't like it,
		--  and try some other statusline plugin
		local statusline = require("mini.statusline")
		-- set use_icons to true if you have a Nerd Font
		statusline.setup({ use_icons = vim.g.have_nerd_font })

		-- You can configure sections in the statusline by overriding their
		-- default behavior. For example, here we set the section for
		-- cursor location to LINE:COLUMN
		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_location = function()
			return "%2l:%-2v"
		end

		-- ... and there is more!
		--  Check out: https://github.com/echasnovski/mini.nvim
	end,
}
