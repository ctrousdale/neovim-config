-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
local config_root = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h')
if config_root ~= '' then
	vim.opt.rtp:prepend(config_root)
	package.path = config_root .. '/lua/?.lua;' .. config_root .. '/lua/?/init.lua;' .. package.path
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require('startup-validation').validate_nvim_install()

require 'options'

require 'keymaps'

require 'lazy-bootstrap'

require 'lazy-plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
