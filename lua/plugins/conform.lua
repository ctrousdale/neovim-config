local languages = require("config.languages")

local function is_generated_hardware_config(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	return filename:match("/nixos/system/[^/]+/hardware%-configuration%.nix$") ~= nil
end

local function format_current_buffer()
	if is_generated_hardware_config(0) then
		vim.notify("Skipping generated NixOS hardware configuration", vim.log.levels.INFO)
		return
	end

	require("conform").format({
		async = true,
		lsp_format = "fallback",
		timeout_ms = 3000,
	})
end

local formatters_by_ft = vim.tbl_extend("force", languages.formatters, {
	nix = function(bufnr)
		if is_generated_hardware_config(bufnr) then
			return {}
		end

		return languages.formatters.nix
	end,
})


return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				format_current_buffer()
			end,
			mode = { "n", "v" },
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = true,
		format_on_save = function(bufnr)
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true }
			if is_generated_hardware_config(bufnr) or disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 3000,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = formatters_by_ft,
		formatters = {
			alejandra = {
				condition = function(_, ctx)
					return not ctx.filename:match("/nixos/system/[^/]+/hardware%-configuration%.nix$")
				end,
			},
		},
	},
}
