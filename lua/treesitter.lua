return {
	settings = {
		ensure_installed = {
			-- Removing, since NixOS needs to manage dynamically
			-- linked libraries itself, not via Mason
			-- 'bash',
			-- 'c',
			-- 'diff',
			-- 'html',
			-- 'lua',
			-- 'luadoc',
			-- 'markdown',
			-- 'markdown_inline',
			-- 'query',
			-- 'vim',
			-- 'vimdoc',
		},
		auto_install = false,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = {
				"ruby",
			},
		},
		indent = {
			enable = true,
			disable = { "ruby" },
		},
	},
}
