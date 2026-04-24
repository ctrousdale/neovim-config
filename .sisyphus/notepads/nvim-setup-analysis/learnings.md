# Learnings

- Added `lua/smoke.lua` with `run()` as non-fatal aggregation and strict assertion entrypoints for targeted policy checks.
- Headless invocation with `-u init.lua` can resolve modules outside this repo unless local `package.path`/runtimepath compatibility is set.
- Key ownership checks are deterministic by reading `plugins.snacks` key specs plus protected Telescope config mappings.
- lazy.nvim can use a single canonical `{ import = "plugins" }` entry in `lua/lazy-plugins.lua`, which removes the need for a secondary `lua/plugins/init.lua` registry module.
- Switching to import-based discovery loads every module under `lua/plugins/`, so previously commented-out plugin files must be marked `enabled = false` to preserve current behavior during registration-only migrations.
- After import topology stabilized, dormant `enabled = false` plugin modules can be removed entirely to reduce startup scan noise and maintenance drift.
- Runtime policy now aligns on an explicit Neovim `0.11+` baseline in both startup validation and `:checkhealth` reporting, removing prior `0.10-dev` drift.
- `nvim-lint` trigger behavior is now explicit (`BufWritePost`, `InsertLeave`), and conform keymap mode is explicit (`{ "n", "v" }`) to avoid ambiguous defaults.
- `lua/options.lua` clipboard setup uses `vim.schedule` (next event-loop tick), so comments should avoid implying a specific `UiEnter` autocmd.
- Under single import discovery (`{ import = "plugins" }`), removing a plugin file (like `lua/plugins/lualine.lua`) is the cleanest way to deactivate it from lazy.nvim resolution.
- `which-key.nvim` group docs belong under `opts.spec`; putting map-like tables in `opts` creates malformed configuration and can silently drift from real key ownership.

- Consolidated fuzzy search ownership on Snacks by removing `lua/plugins/telescope.lua` and keeping picker/search workflows (`files`, `grep`, `buffers`, `help`, `diagnostics`) in `lua/plugins/snacks.lua`.
- Replaced Telescope-backed LSP fuzzy maps in `lua/plugins/nvim-lspconfig.lua` with direct `Snacks.picker` calls for references, definitions, implementations, symbols, workspace symbols, and type definitions.

- `lua/smoke.lua` key ownership now derives from active owner modules (`keymap_owner_modules`) instead of hardcoded Telescope mappings, so policy checks follow the current Snacks-only architecture.
- Strict keymap failures for this repo were coming from duplicate entries inside `lua/plugins/snacks.lua`, not cross-module overlap; removing the duplicate key specs clears the protected mapping policy without changing runtime behavior.
- Global navigation keys in `lua/keymaps.lua` should stay free when `vim-tmux-navigator` is installed, otherwise pane movement ownership becomes ambiguous between plain window commands and tmux-aware navigation.
- Inspecting plugin specs with `require()` after `lazy.nvim` startup can show injected default key specs that are not present in the repo source; `dofile(package.searchpath(...))` avoids that false-positive for ownership auditing.
- For protected Snacks keys already provided by upstream defaults, redefining the same lhs in repo config creates same-owner duplicates under `lazy.nvim` normalization even when the mapping bodies are identical.
- Splitting helper code under `lua/plugins/` would risk `lazy.nvim` importing those helpers as plugin specs via `{ import = "plugins" }`, so extracted hotspot modules should live outside the plugin import namespace and be required from the thin spec wrappers.
- Keeping `lua/plugins/snacks.lua` and `lua/plugins/nvim-lspconfig.lua` as small entrypoints while moving options, keys, attach logic, diagnostics, and server setup into `lua/config/*` materially reduces hotspot size without changing key/provider ownership.
- Removing CWD-based bootstrap from `init.lua` is safe only if module discovery is anchored to `vim.env.MYVIMRC`; using the loaded config root keeps `require('smoke')` and other local modules resolvable in headless runs without trusting arbitrary project directories.
- Provider policy strict checks pass once `vim.g.loaded_node_provider`, `vim.g.loaded_ruby_provider`, and `vim.g.loaded_perl_provider` are explicitly set to `0` in early init.
- Final-wave keymap policy coverage now includes `<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>` in `lua/smoke.lua` protected mappings.
- Provider policy can cheaply enforce architecture boundaries by checking module-path presence for required/forbidden owner modules (`plugins.snacks`, `plugins.mini`, `plugins.telescope`, `plugins.lualine`) without loading plugin specs.
- Protected `<C-h/j/k/l>` checks only become real ownership audits when `keymap_owner_modules` includes `plugins.vim-tmux-navigator`; otherwise those keys are listed but never sourced for owner analysis.
- Neovim treats `<leader>f` plus `<leader>ff` as normal prefix-mapping behavior, not a broken collision; the shorter map waits up to `timeoutlen` unless it is marked `<nowait>` and wins precedence.
- With this repo's `vim.opt.timeoutlen = 300`, leader prefixes stay fairly responsive while still allowing multi-key groups; if a single-key leader action feels laggy, the fix is usually namespace placement or selective `<nowait>`, not disabling prefix groups.
- `which-key.nvim` already reads `desc` from real keymaps, so repo-wide group labels should stay in `opts.spec` only for namespace documentation or virtual groups, while concrete plugin mappings keep their own `desc` near the actual binding source.
