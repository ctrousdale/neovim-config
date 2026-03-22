local function set_keymaps(keys)
	for _, key in ipairs(keys or {}) do
		local opts = {}
		for opt_name, opt_value in pairs(key) do
			if type(opt_name) == "string" and opt_name ~= "mode" then
				opts[opt_name] = opt_value
			end
		end

		vim.keymap.set(key.mode or "n", key[1], key[2], opts)
	end
end

local function setup_module(module_name, opts)
	local module = require(module_name)
	if type(module) == "table" and type(module.setup) == "function" then
		module.setup(opts or {})
	end
	return module
end

local registry = {
	{ src = "https://github.com/tpope/vim-sleuth.git", name = "vim-sleuth" },
	{ src = "https://github.com/folke/which-key.nvim.git", name = "which-key.nvim" },
	{ src = "https://github.com/tiagovla/tokyodark.nvim.git", name = "tokyodark.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter.git", name = "nvim-treesitter" },
	{ src = "https://github.com/folke/flash.nvim.git", name = "flash.nvim" },
	{ src = "https://github.com/folke/snacks.nvim.git", name = "snacks.nvim" },
	{ src = "https://github.com/folke/lsp-colors.nvim.git", name = "lsp-colors.nvim" },
	{ src = "https://github.com/akinsho/bufferline.nvim.git", name = "bufferline.nvim", version = "*" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons.git", name = "nvim-web-devicons" },
	{ src = "https://github.com/windwp/nvim-autopairs.git", name = "nvim-autopairs" },
	{ src = "https://github.com/folke/trouble.nvim.git", name = "trouble.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim.git", name = "lualine.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-lint.git", name = "nvim-lint" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim.git", name = "gitsigns.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-dap.git", name = "nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui.git", name = "nvim-dap-ui" },
	{ src = "https://github.com/nvim-neotest/nvim-nio.git", name = "nvim-nio" },
	{ src = "https://github.com/williamboman/mason.nvim.git", name = "mason.nvim" },
	{ src = "https://github.com/jay-babu/mason-nvim-dap.nvim.git", name = "mason-nvim-dap.nvim" },
	{ src = "https://github.com/leoluz/nvim-dap-go.git", name = "nvim-dap-go" },
	{ src = "https://github.com/windwp/nvim-ts-autotag.git", name = "nvim-ts-autotag" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim.git", name = "telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim.git", name = "plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim.git", name = "telescope-fzf-native.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim.git", name = "telescope-ui-select.nvim" },
	{ src = "https://github.com/folke/lazydev.nvim.git", name = "lazydev.nvim" },
	{ src = "https://github.com/saghen/blink.cmp.git", name = "blink.cmp", version = "1.*" },
	{ src = "https://github.com/L3MON4D3/LuaSnip.git", name = "LuaSnip", version = "2.*" },
	{ src = "https://github.com/neovim/nvim-lspconfig.git", name = "nvim-lspconfig" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim.git", name = "mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim.git", name = "mason-tool-installer.nvim" },
	{ src = "https://github.com/j-hui/fidget.nvim.git", name = "fidget.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim.git", name = "conform.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim.git", name = "todo-comments.nvim" },
	{ src = "https://github.com/echasnovski/mini.nvim.git", name = "mini.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim.git", name = "render-markdown.nvim" },
	{ src = "https://github.com/andymass/vim-matchup.git", name = "vim-matchup" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator.git", name = "vim-tmux-navigator" },
	{ src = "https://github.com/folke/noice.nvim.git", name = "noice.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim.git", name = "nui.nvim" },
	{ src = "https://github.com/rcarriga/nvim-notify.git", name = "nvim-notify" },
	{ src = "https://codeberg.org/esensar/nvim-dev-container", name = "nvim-dev-container" },
}

vim.pack.add(registry, { confirm = false, load = true })

local which_key = require("plugins.which-key")
local colorscheme = require("colorscheme")
local treesitter = require("treesitter")
local flash = require("plugins.flash")
local snacks = require("plugins.snacks")
local bufferline = require("plugins.bufferline")
local trouble = require("plugins.trouble")
local lualine = require("plugins.lualine")
local lint = require("plugins.lint")
local gitsigns = require("plugins.gitsigns")
local debug = require("plugins.debug")
local autotag = require("plugins.autotag")
local telescope = require("plugins.telescope")
local lazydev = require("plugins.lazydev")
local blink = require("plugins.blink")
local lspconfig = require("plugins.nvim-lspconfig")
local conform = require("plugins.conform")
local todo_comments = require("plugins.todo-comments")
local mini = require("plugins.mini")
local render_markdown = require("plugins.render-markdown")
local vim_tmux_navigator = require("plugins.vim-tmux-navigator")
local noice = require("plugins.noice")
local nvim_dev_container = require("plugins.nvim-dev-container")

setup_module("which-key", vim.tbl_deep_extend("force", {
	delay = which_key.delay,
	icons = which_key.icons,
	spec = which_key.spec,
}, which_key.shortcuts or {}))

colorscheme.apply()
setup_module(treesitter.main or "nvim-treesitter", treesitter.settings)
setup_module("flash", flash.settings)
set_keymaps(flash.mappings)
setup_module("snacks", snacks.settings)
set_keymaps(snacks.mappings)
setup_module("bufferline", bufferline.settings)
setup_module("nvim-autopairs", {})
setup_module("trouble", trouble.settings)
set_keymaps(trouble.mappings)
setup_module("lualine", lualine.build_settings())
lint.setup()
setup_module("gitsigns", gitsigns.settings)
setup_module("nvim-ts-autotag", autotag.settings)
telescope.config()
setup_module("lazydev", lazydev.settings)
setup_module("luasnip", blink.support[1].settings)
setup_module("blink.cmp", blink.settings)
setup_module("mason", {})
setup_module("fidget", {})
debug.activate()
set_keymaps(debug.mappings)
lspconfig.config()
setup_module("conform", conform.settings)
set_keymaps(conform.mappings)
setup_module("todo-comments", todo_comments.settings)
mini.config()
setup_module("render-markdown", render_markdown.settings)
set_keymaps(vim_tmux_navigator.mappings)
setup_module("noice", noice.settings)
nvim_dev_container.activate()
