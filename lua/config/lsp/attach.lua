local M = {}

local function client_supports_method(client, method, bufnr)
	return client:supports_method(method, bufnr)
end

local function setup_document_highlight(client, event)
	if not client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
		return
	end

	local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		buffer = event.buf,
		group = highlight_augroup,
		callback = vim.lsp.buf.document_highlight,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = event.buf,
		group = highlight_augroup,
		callback = vim.lsp.buf.clear_references,
	})

	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
		callback = function(event2)
			vim.lsp.buf.clear_references()
			vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
		end,
	})
end

local function setup_inlay_hints(client, event, map)
	if not client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
		return
	end

	map("<leader>th", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
	end, "[T]oggle Inlay [H]ints")
end

local function on_attach(event)
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end

	map("<leader>ca", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
	map("<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")

	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if not client then
		return
	end

	setup_document_highlight(client, event)
	setup_inlay_hints(client, event, map)
end

function M.setup()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = on_attach,
	})
end

return M
