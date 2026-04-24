# Issues

- Strict keymap policy currently fails for protected mappings due to Snacks/Telescope overlap and duplicate Snacks declarations (`<leader>n`, `<leader>sb`).
- Strict provider policy currently fails because `vim.g.loaded_node_provider` is unset (policy expects explicit `0`).
- No new registration issues surfaced in this migration; the required headless smoke command completed successfully after moving specs under `lua/plugins/`.
- `lua/lazy-plugins.lua` still contained large inherited Kickstart scaffolding blocks that misdescribed the active single-import architecture and increased config noise.
- `lua/health.lua` enforced `0.10-dev` while `lua/startup-validation.lua` enforced `0.11`, creating baseline policy drift.
- `lua/lazy-plugins.lua` included a `LazyVimStarted` autocmd that is distribution-specific and dead in this repo context.
- `lua/plugins/which-key.lua` had invalid structure (top-level fields mixed with malformed command mappings), causing which-key ownership docs to be unreliable until normalized.

- Strict provider policy check still fails on the known global-setting issue: vim.g.loaded_node_provider is unset; migration introduced no Telescope-related smoke failures.

- `assert_keymap_policy()` no longer reports synthetic Telescope overlap after Telescope removal; current strict failure is now the real duplicate owner counts inside `plugins.snacks` for `<leader>n` and `<leader>sb`.
- Resolved duplicate protected key owners in `lua/plugins/snacks.lua` for `<leader>n` and `<leader>sb`, and removed competing global `<C-h/j/k/l>` mappings from `lua/keymaps.lua` so tmux navigation has a single owner again.
- Strict keymap policy now passes after switching `lua/smoke.lua` to audit source specs directly; the remaining earlier duplicate counts were caused by `lazy.nvim` injecting Snacks default keys into the runtime spec table.
- Follow-up blocker after removing CWD mutation: headless `-u init.lua` lost local module resolution (`module 'smoke' not found`) until init path setup was anchored to `vim.env.MYVIMRC` instead of `vim.fn.getcwd()`.
- Provider strict failure from unset globals is resolved by explicitly setting legacy provider globals to `0` in `init.lua`.
- F1 continued rejecting until provider policy also asserted owner boundaries; global provider flags alone were not sufficient for final-wave policy acceptance.
- F1 keymap rejection persisted because tmux navigation keys were protected but their owner module (`plugins.vim-tmux-navigator`) was not in `keymap_owner_modules`, leaving `<C-h/j/k/l>` effectively unaudited.

- Key ownership smoke coverage is currently partial: `lua/smoke.lua` only inspects `plugins.snacks` and `plugins.vim-tmux-navigator` specs (`keymap_owner_modules`), so keymaps created via runtime helpers (for example `Snacks.toggle.*:map(...)` in `lua/config/snacks/init.lua`) are outside duplication checks.
- Protected mappings include `<leader>n` and `<leader>sb` in `lua/smoke.lua`, but those lhs do not exist in repo key specs (`lua/config/snacks/keys.lua`), so strict checks can pass while ownership effectively depends on upstream/runtime-injected defaults.
- `vim-tmux-navigator` likely keeps plugin-side default mappings because no `vim.g.tmux_navigator_no_mappings` guard is set in repo source; combined with explicit `keys = { ... }` in `lua/plugins/vim-tmux-navigator.lua`, ownership can be ambiguous and invisible to source-spec-only smoke counting.
- Prefix-family friction remains on `<leader>f` (`lua/plugins/conform.lua`) versus `<leader>ff` (`lua/config/snacks/keys.lua`): valid hierarchy, but user-perceived latency depends on `vim.opt.timeoutlen = 300` in `lua/options.lua`.
- Discoverability drift: `lua/plugins/vim-tmux-navigator.lua` key specs omit `desc`, and `lua/config/snacks/keys.lua` uses `desc = "which_key_ignore"` for `<c-_>`, which is a sentinel-like string rather than user-facing intent.
