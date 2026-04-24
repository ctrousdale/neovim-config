local snacks_init = require("config.snacks.init")
local snacks_keys = require("config.snacks.keys")
local snacks_options = require("config.snacks.options")

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = snacks_options.get(),
	keys = snacks_keys.get(),
	init = snacks_init.setup,
}
