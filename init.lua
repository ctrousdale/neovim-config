-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
local init_path = vim.env.MYVIMRC
if not init_path or init_path == "" then
	init_path = debug.getinfo(1, "S").source:sub(2)
end

local config_root = vim.fn.fnamemodify(init_path, ":p:h")
if config_root ~= "" then
	vim.opt.rtp:prepend(config_root)
	package.path = config_root .. "/lua/?.lua;" .. config_root .. "/lua/?/init.lua;" .. package.path
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require("startup-validation").validate_nvim_install()

require("options")

local function dockerfile_or_compose(path, bufnr)
	local first_lines = vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)

	for _, line in ipairs(first_lines) do
		local key = line:match("^%s*([%w_-]+)%s*:")
		if
			key == "services"
			or key == "networks"
			or key == "volumes"
			or key == "configs"
			or key == "secrets"
			or key == "version"
			or key == "name"
		then
			return "yaml.docker-compose"
		end
	end

	return "dockerfile"
end

vim.filetype.add({
	filename = {
		[".dockerfile"] = dockerfile_or_compose,
		["compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["docker-compose.yml"] = "yaml.docker-compose",
	},
	pattern = {
		[".*%.dockerfile"] = dockerfile_or_compose,
	},
})

require("keymaps")

require("lazy-bootstrap")

require("lazy-plugins")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
