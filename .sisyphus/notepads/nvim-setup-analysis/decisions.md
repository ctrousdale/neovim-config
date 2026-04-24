# Decisions

- Kept smoke checks dependency-light and local to one module (`lua/smoke.lua`) with `return M` export pattern.
- `run()` is intentionally non-fatal for CI-friendly smoke execution, while `assert_*` functions are strict and raise on policy violations.
- Provider policy chosen: legacy providers (`node`, `ruby`, `perl`) must be explicitly disabled; missing executables are warnings unless strict policy is violated.
- Standardized plugin registration on `lua/lazy-plugins.lua` with a single `{ import = "plugins" }` spec root and removed `lua/plugins/init.lua` as an extra registry layer.
- Moved top-level `lua/colorscheme.lua` and `lua/treesitter.lua` into `lua/plugins/` and retained dormant plugin files by setting `enabled = false` instead of deleting or activating them.
- With registration complete and stable, removed dormant plugin modules (`copilot.lua`, `lazygit.lua`, `minimap.lua`, `neorg.lua`) and cleaned stale Kickstart scaffold comments in `lua/lazy-plugins.lua` while keeping the single `{ import = "plugins" }` owner model.
- Runtime baseline policy is explicitly Neovim `0.11+` across startup and health checks; external tool absence remains warning-level unless explicitly required.
- Removed dead `LazyVimStarted` autocmd from `lua/lazy-plugins.lua` and kept lazy setup focused on repo-local behavior only.
- Lint and format invocation semantics must be explicit: lint triggers are save/insert-leave only, and conform keymap mode is explicitly `{ "n", "v" }`.
- Statusline ownership remains with `mini.statusline`; removed `lualine` plugin module instead of leaving an inert/dead spec.
- Which-key is kept as discovery-only documentation via valid `opts.spec` group registrations for surviving prefixes (`<leader>s`, `<leader>t`, `<leader>h`).

- Chose hard removal of `lua/plugins/telescope.lua` (instead of disabling) to enforce a single active owner model for search/LSP fuzzy UI and eliminate protected key overlap at source.
- Kept existing LSP key workflows (`grr`, `gri`, `grd`, `grt`, `gO`, `gW`) and swapped implementations to `Snacks.picker.*` for minimal behavioral drift during consolidation.
- Restored single-owner navigation by removing global `<C-h/j/k/l>` split maps from `lua/keymaps.lua` and leaving `vim-tmux-navigator` as the sole owner of cross-pane movement.
- Kept the surviving Snacks protected keys as single canonical definitions: `<leader>n` uses notifier history and `<leader>sb` remains the search namespace entry for buffer lines.
- Updated `lua/smoke.lua` to load owner specs from module files before falling back to `require()`, so key ownership checks reflect repo-defined mappings instead of `lazy.nvim` runtime key injection.
- `<leader>n` and `<leader>sb` are now intentionally left undefined in repo-local `lua/plugins/snacks.lua`; their single owner is the built-in Snacks default key spec at runtime.
- Kept `lua/plugins/snacks.lua` and `lua/plugins/nvim-lspconfig.lua` as the only lazy-imported plugin specs, and moved the extracted hotspot helpers to `lua/config/snacks/` and `lua/config/lsp/` so the import tree stays plugin-spec-only.
- Replaced unsafe `cwd`-derived runtimepath/package.path bootstrap with `vim.env.MYVIMRC`-derived `config_root` bootstrap in `init.lua` so startup/module resolution is deterministic to the active config file and not hijackable by arbitrary working directories.
- Set `vim.g.loaded_node_provider`, `vim.g.loaded_ruby_provider`, and `vim.g.loaded_perl_provider` explicitly in `init.lua` to enforce provider disable policy at startup.
- Expanded smoke protected mapping policy to include `<C-h/j/k/l>` to keep strict key ownership checks aligned with plan requirements.
- Extended `assert_provider_policy()` to include strict owner-boundary checks: require `plugins.snacks` and `plugins.mini`, and reject `plugins.telescope` and `plugins.lualine`, while retaining existing legacy provider-global enforcement.
