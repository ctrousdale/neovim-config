# Migrate Neovim Config From lazy.nvim To vim.pack

## TL;DR

> **Quick Summary**: Replace the current lazy.nvim bootstrap and lazy-spec plugin wiring with a direct, eager-loading `vim.pack` setup for Neovim `0.12`, while preserving the current plugin set and visible behavior as closely as possible.
>
> **Deliverables**:
> - `vim.pack`-based bootstrap and plugin registration
> - Converted active plugin modules with explicit eager setup
> - Removed lazy-specific runtime/doc references and retired `lazy-lock.json`
>
> **Estimated Effort**: Large
> **Parallel Execution**: YES - 2 implementation waves plus final verification
> **Critical Path**: Task 1 -> Task 2 -> Task 7 -> Task 10 -> F1-F4

---

## Context

### Original Request
Remove all references to LazyVim/lazy.nvim and convert this Neovim config to the new built-in `vim.pack` package manager in Neovim `v0.12`. Lazy loading is not required. Keep edits as clean and minimal as possible.

### Interview Summary
**Key Discussions**:
- The repo is a lazy.nvim-based kickstart-style config, not the LazyVim distro.
- The user chose a **clean direct rewrite** instead of a compatibility adapter.
- No new lazy-loading behavior should be introduced.
- No new automated test or CI setup should be added as part of this migration.

**Research Findings**:
- Current bootstrap path is `init.lua` -> `lua/lazy-bootstrap.lua` -> `lua/lazy-plugins.lua`.
- Most active files under `lua/plugins/` are lazy.nvim spec tables and must be translated, not merely re-pointed.
- Current verification is limited to headless startup validation and `:checkhealth` style checks in `lua/startup-validation.lua` and `lua/health.lua`.
- Official `vim.pack` is intentionally small: install/load packages via `vim.pack.add(...)`, then configure plugins explicitly.

### Metis Review
**Identified Gaps** (addressed):
- Lock down “minimal” as behavior-preserving migration only: no new plugins, no adapter layer, no unrelated cleanup.
- Treat lockfile policy as part of the migration: retire `lazy-lock.json`, allow `nvim-pack-lock.json` to replace it if generated, and do not hand-edit either lockfile.
- Add explicit acceptance checks for removing lazy-specific references like `LazyVimStarted`, `VeryLazy`, `:Lazy`, and `require("lazy")`.
- Raise version validation from Neovim `0.11`/`0.10-dev` assumptions to `0.12` as part of the cutover.

---

## Work Objectives

### Core Objective
Move this repo from lazy.nvim-managed plugin specs to Neovim `0.12` `vim.pack` with eager loading, while preserving the existing active plugin set and avoiding broader config redesign.

### Concrete Deliverables
- `init.lua` loads a `vim.pack`-based plugin path instead of `lazy-bootstrap`/`lazy-plugins`
- Active plugin modules under `lua/`, `lua/plugins/`, and related validation files are translated away from lazy.nvim semantics
- Lazy-specific artifacts and documentation references are removed or replaced

### Definition of Done
- [ ] `grep -RInE 'require\("lazy"\)|lazy.nvim|LazyVimStarted|VeryLazy|:Lazy|lazy-lock.json' /home/chandler/repos/dotfiles/nvim --exclude-dir=.sisyphus` returns no matches in active config files
- [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua print(vim.fn.has('nvim-0.12') == 1 and 'OK_NVIM_012' or 'BAD_NVIM_VERSION')" +qa` prints `OK_NVIM_012`
- [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless +qa` exits `0`
- [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+checkhealth kickstart.nvim" +qa` exits `0` without new migration-induced health errors

### Must Have
- Preserve the current active plugin set unless a plugin is explicitly declared out of scope
- Preserve existing keymaps/commands/behavior where lazy-loading previously hid setup behind events or commands
- Keep module organization close to the current layout; prefer direct rewrites over structural invention

### Must NOT Have (Guardrails)
- No compatibility shim or custom DSL replacing lazy specs
- No new CI, test framework, or unrelated Neovim modernization work
- No plugin additions, aesthetic cleanup, or generalized refactors beyond `vim.pack` migration needs
- No hand-editing of generated lockfiles

---

## Verification Strategy

> **ZERO HUMAN INTERVENTION** — all verification is agent-executed.

### Test Decision
- **Infrastructure exists**: NO repo-level automated test suite; only runtime validation/health checks exist
- **Automated tests**: None added in this migration
- **Framework**: Headless Neovim commands plus grep-based assertions

### QA Policy
Every task must use executable checks with `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles` so Neovim loads this repo as the config source.

- **Config startup**: `nvim --headless`
- **Static regression checks**: `grep`
- **Behavior checks**: targeted `require(...)`, commands, or plugin API calls in headless Neovim
- **Evidence**: save outputs under `.sisyphus/evidence/task-{N}-*.txt`
- **Evidence setup**: create `.sisyphus/evidence/` and `.sisyphus/evidence/final-qa/` before the first redirected QA command

---

## Execution Strategy

### Parallel Execution Waves

Wave 1 (Start Immediately — foundation and low-coupling conversions):
- Task 1: Cut over bootstrap entrypoint and version guards
- Task 2: Replace central plugin registry and retire lazy bootstrap modules
- Task 3: Update docs and lockfile/artifact policy
- Task 4: Convert colorscheme and key-discovery modules
- Task 5: Convert treesitter/markup helpers
- Task 6: Convert formatting, lint, and autopairs hooks

Wave 2 (After Wave 1 — higher-coupling plugin stacks):
- Task 7: Convert search/picker stack
- Task 8: Convert status/window/notification UI stack
- Task 9: Convert completion and dev-experience stack
- Task 10: Convert LSP and health/version integration
- Task 11: Convert diagnostics, git, and debug tooling
- Task 12: Convert remaining active command/navigation helpers and devcontainer integration

Wave FINAL (After all implementation tasks — 4-way review):
- F1: Plan compliance audit
- F2: Code quality review
- F3: Real executable QA sweep
- F4: Scope fidelity check

### Dependency Matrix

- **1**: None -> 2, 4, 5, 6
- **2**: 1 -> 7, 8, 9, 10, 11, 12
- **3**: None -> F1, F4
- **4**: 1 -> 8, 9
- **5**: 1 -> 7, 10
- **6**: 1 -> 10, 11
- **7**: 2, 5 -> F1, F2, F3, F4
- **8**: 2, 4 -> F1, F2, F3, F4
- **9**: 2, 4 -> 10, F1, F2, F3, F4
- **10**: 2, 5, 6, 9 -> F1, F2, F3, F4
- **11**: 2, 6 -> F1, F2, F3, F4
- **12**: 2 -> F1, F2, F3, F4

### Agent Dispatch Summary

- **Wave 1**: 6 agents — T1 `quick`, T2 `deep`, T3 `writing`, T4 `quick`, T5 `unspecified-high`, T6 `unspecified-high`
- **Wave 2**: 6 agents — T7 `unspecified-high`, T8 `unspecified-high`, T9 `unspecified-high`, T10 `deep`, T11 `unspecified-high`, T12 `quick`
- **FINAL**: 4 agents — F1 `oracle`, F2 `unspecified-high`, F3 `unspecified-high`, F4 `deep`

---

## TODOs

- [x] 1. Cut over bootstrap entrypoint and version guards

  **What to do**:
  - Replace `init.lua` lazy bootstrap wiring with the new `vim.pack` entrypoint path.
  - Update startup/version validation to require Neovim `0.12` instead of `0.11`.
  - Ensure bootstrap changes still load `options`, `keymaps`, and the new plugin entry sequence in a minimal way.
  - Create `.sisyphus/evidence/` and `.sisyphus/evidence/final-qa/` so all later QA commands can write evidence files successfully.

  **Must NOT do**:
  - Do not introduce a compatibility layer that emulates lazy.nvim behavior.
  - Do not change unrelated option or keymap modules.

  **Recommended Agent Profile**:
  - **Category**: `quick` - tight entrypoint rewrite with clear file boundaries.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 2, 4, 5, 6
  - **Blocked By**: None

  **References**:
  - `init.lua:10` - startup validation currently runs before plugin bootstrap.
  - `init.lua:16` - current `require('lazy-bootstrap')` call to remove.
  - `init.lua:18` - current `require('lazy-plugins')` call to replace.
  - `lua/startup-validation.lua:3` - version check currently targets `0.11` and must be raised to `0.12`.
  - `runtime/doc/pack.txt` (`:h vim.pack`, `:h vim.pack-examples`) - official `vim.pack` bootstrap shape and `add()` behavior.

  **Acceptance Criteria**:
  - [ ] `grep -n "lazy-bootstrap\|lazy-plugins" /home/chandler/repos/dotfiles/nvim/init.lua` returns no matches.
  - [ ] `grep -n "0.11\|0.10-dev" /home/chandler/repos/dotfiles/nvim/lua/startup-validation.lua /home/chandler/repos/dotfiles/nvim/lua/health.lua` returns no stale version-floor matches.
  - [ ] `test -d /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence && test -d /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa` succeeds.

  **QA Scenarios**:
  ```text
  Scenario: Bootstrap path loads on Neovim 0.12
    Tool: Bash
    Preconditions: Task 1 changes applied.
    Steps:
      1. Run `mkdir -p /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa`.
      2. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua print(vim.fn.has('nvim-0.12') == 1 and 'OK_NVIM_012' or 'BAD_NVIM_VERSION')" +qa > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/task-1-version-check.txt 2>&1`.
      3. Inspect the saved output for `OK_NVIM_012`.
    Expected Result: command exits 0 and output contains `OK_NVIM_012`.
    Failure Indicators: exit non-zero, Lua error, or `BAD_NVIM_VERSION` in evidence.
    Evidence: .sisyphus/evidence/task-1-version-check.txt

  Scenario: Bootstrap no longer references lazy modules
    Tool: Bash
    Preconditions: Task 1 changes applied.
    Steps:
      1. Run `grep -n "lazy-bootstrap\|lazy-plugins" /home/chandler/repos/dotfiles/nvim/init.lua > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/task-1-bootstrap-grep.txt 2>&1`.
      2. Confirm the grep output file is empty and command exits 1.
    Expected Result: no lazy bootstrap references remain in `init.lua`.
    Failure Indicators: any matched line in the evidence file.
    Evidence: .sisyphus/evidence/task-1-bootstrap-grep.txt
  ```

  **Commit**: NO

- [x] 2. Replace central plugin registry and retire lazy bootstrap modules

  **What to do**:
  - Replace `lua/lazy-plugins.lua` with the canonical `vim.pack.add({...})` registry and explicit eager setup orchestration.
  - Remove `lua/lazy-bootstrap.lua` usage entirely and delete the file if no longer needed.
  - Rework `lua/plugins/init.lua` so it no longer returns nested lazy specs and instead exposes direct setup/module loading in the smallest viable way.

  **Must NOT do**:
  - Do not invent a new spec DSL mirroring lazy.nvim.
  - Do not silently drop active plugins from `lua/plugins/init.lua`.

  **Recommended Agent Profile**:
  - **Category**: `deep` - this defines package order, load semantics, and the migration center of gravity.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential start of Wave 1
  - **Blocks**: 7, 8, 9, 10, 11, 12
  - **Blocked By**: 1

  **References**:
  - `lua/lazy-bootstrap.lua:1` - current lazy.nvim clone/bootstrap logic to eliminate.
  - `lua/lazy-plugins.lua:12` - current `require("lazy").setup(...)` entrypoint.
  - `lua/lazy-plugins.lua:106` - stale `LazyVimStarted` autocmd that must be removed or replaced explicitly.
  - `lua/plugins/init.lua:5` - active plugin list that defines in-scope modules.
  - `runtime/doc/pack.txt` (`:h vim.pack`) - supported `vim.pack` spec fields and lockfile behavior.

  **Acceptance Criteria**:
  - [ ] `grep -RInE 'require\("lazy"\)|LazyVimStarted' /home/chandler/repos/dotfiles/nvim/lua --include='*.lua'` returns no matches.
  - [ ] `grep -RIn "vim.pack.add" /home/chandler/repos/dotfiles/nvim` returns at least one active bootstrap location.

  **QA Scenarios**:
  ```text
  Scenario: Central registry installs and loads via vim.pack
    Tool: Bash
    Preconditions: Tasks 1-2 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless +qa > .sisyphus/evidence/task-2-headless-startup.txt 2>&1`.
      2. Confirm exit code 0 and no Lua bootstrap errors in the evidence file.
    Expected Result: headless startup succeeds using `vim.pack` wiring.
    Failure Indicators: messages mentioning `lazy.nvim`, missing modules, or startup abort.
    Evidence: .sisyphus/evidence/task-2-headless-startup.txt

  Scenario: Lazy registry tokens are retired
    Tool: Bash
    Preconditions: Tasks 1-2 complete.
    Steps:
      1. Run `grep -RInE 'require\("lazy"\)|LazyVimStarted|lazy.nvim' /home/chandler/repos/dotfiles/nvim/lua --include='*.lua' > .sisyphus/evidence/task-2-lazy-token-grep.txt 2>&1`.
      2. Confirm the command exits 1 and the evidence file is empty.
    Expected Result: no active Lua module still depends on lazy bootstrap/runtime tokens.
    Failure Indicators: any matched line in the evidence file.
    Evidence: .sisyphus/evidence/task-2-lazy-token-grep.txt
  ```

  **Commit**: YES
  - Message: `refactor(nvim): replace lazy bootstrap with vim.pack`
  - Files: `init.lua`, `lua/lazy-bootstrap.lua`, `lua/lazy-plugins.lua`, `lua/plugins/init.lua`

- [x] 3. Update docs and artifact policy

  **What to do**:
  - Update repo docs that currently direct future work toward lazy bootstrap/list files.
  - Retire `lazy-lock.json` from the workflow and document that `nvim-pack-lock.json` is the generated replacement if execution produces it.
  - Remove stale inline references to `:Lazy` where they would mislead maintenance.

  **Must NOT do**:
  - Do not hand-author `nvim-pack-lock.json`.
  - Do not expand docs beyond migration-relevant guidance.

  **Recommended Agent Profile**:
  - **Category**: `writing` - small doc cleanup with artifact-policy guardrails.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: F1, F4
  - **Blocked By**: None

  **References**:
  - `AGENTS.md` - currently points maintainers at lazy bootstrap/list files and mentions `lazy-lock.json` ownership.
  - `lua/AGENTS.md` - currently tells maintainers to reference `lazy-plugins.lua`.
  - `lazy-lock.json` - lazy.nvim-managed artifact to retire.

  **Acceptance Criteria**:
  - [ ] `grep -RInE ':Lazy|lazy-lock.json|lazy-plugins.lua|lazy-bootstrap.lua' /home/chandler/repos/dotfiles/nvim/AGENTS.md /home/chandler/repos/dotfiles/nvim/lua/AGENTS.md` returns no stale maintenance guidance.
  - [ ] `test ! -e /home/chandler/repos/dotfiles/nvim/lazy-lock.json` succeeds once cleanup is complete.

  **QA Scenarios**:
  ```text
  Scenario: Docs point to vim.pack-era entrypoints only
    Tool: Bash
    Preconditions: Task 3 changes applied.
    Steps:
      1. Run `grep -RInE ':Lazy|lazy-lock.json|lazy-plugins.lua|lazy-bootstrap.lua' /home/chandler/repos/dotfiles/nvim/AGENTS.md /home/chandler/repos/dotfiles/nvim/lua/AGENTS.md > .sisyphus/evidence/task-3-docs-grep.txt 2>&1`.
      2. Confirm exit code 1 and empty evidence file.
    Expected Result: docs no longer instruct maintainers to use lazy.nvim artifacts.
    Failure Indicators: any stale doc line in the evidence file.
    Evidence: .sisyphus/evidence/task-3-docs-grep.txt

  Scenario: Old lazy lockfile is retired cleanly
    Tool: Bash
    Preconditions: Task 3 cleanup applied.
    Steps:
      1. Run `test ! -e /home/chandler/repos/dotfiles/nvim/lazy-lock.json; printf '%s\n' $? > .sisyphus/evidence/task-3-lockfile-check.txt`.
      2. Confirm the evidence file contains `0`.
    Expected Result: `lazy-lock.json` is gone from the repo.
    Failure Indicators: evidence file contains non-zero or the file still exists.
    Evidence: .sisyphus/evidence/task-3-lockfile-check.txt
  ```

  **Commit**: NO

- [x] 4. Convert colorscheme and key-discovery modules

  **What to do**:
  - Translate `lua/colorscheme.lua` away from lazy-spec fields into direct eager setup.
  - Translate `lua/plugins/which-key.lua` so key registration/setup works without lazy events or opts indirection.
  - Preserve current colorscheme and key-discovery behavior.

  **Must NOT do**:
  - Do not change theme selection or key descriptions unless required by the API shift.
  - Do not fold these modules into the central bootstrap file.

  **Recommended Agent Profile**:
  - **Category**: `quick` - low-coupling eager-setup conversion.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 8, 9
  - **Blocked By**: 1

  **References**:
  - `lua/colorscheme.lua` - existing colorscheme spec/config to preserve.
  - `lua/plugins/which-key.lua` - existing key-discovery lazy spec to translate.
  - `init.lua:4` - leader key is set before plugin loading and must remain compatible.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua print(vim.g.colors_name or 'NO_COLORSCHEME')" +qa` does not print `NO_COLORSCHEME`.
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('which-key')" +qa` exits `0`.

  **QA Scenarios**:
  ```text
  Scenario: Colorscheme still applies on startup
    Tool: Bash
    Preconditions: Tasks 1, 2, and 4 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua print(vim.g.colors_name or 'NO_COLORSCHEME')" +qa > .sisyphus/evidence/task-4-colorscheme.txt 2>&1`.
      2. Confirm output does not contain `NO_COLORSCHEME`.
    Expected Result: configured colorscheme is active after eager startup.
    Failure Indicators: `NO_COLORSCHEME` or startup error in evidence.
    Evidence: .sisyphus/evidence/task-4-colorscheme.txt

  Scenario: which-key module is eager-load safe
    Tool: Bash
    Preconditions: Tasks 1, 2, and 4 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('which-key')" +qa > .sisyphus/evidence/task-4-which-key.txt 2>&1`.
      2. Confirm exit code 0 and no Lua errors.
    Expected Result: `which-key` can be required successfully after startup.
    Failure Indicators: module-not-found or setup error in evidence.
    Evidence: .sisyphus/evidence/task-4-which-key.txt
  ```

  **Commit**: NO

- [x] 5. Convert treesitter and markup helpers

  **What to do**:
  - Translate `lua/treesitter.lua` from lazy-spec form into direct eager setup.
  - Convert `lua/plugins/autotag.lua` and `lua/plugins/render-markdown.lua` so their dependencies and setup no longer rely on lazy-managed ordering.
  - Preserve current syntax, markdown, and tag-editing behavior.

  **Must NOT do**:
  - Do not expand treesitter language coverage or plugin scope.
  - Do not defer build/update hooks unless the plugin truly requires `PackChanged` handling.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` - moderate dependency/order risk with parser-related plugins.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 7, 10
  - **Blocked By**: 1

  **References**:
  - `lua/treesitter.lua` - current treesitter spec and setup hub.
  - `lua/plugins/autotag.lua` - tag helper depending on treesitter behavior.
  - `lua/plugins/render-markdown.lua` - markdown rendering setup and dependency usage.
  - `runtime/doc/pack.txt` (`PackChanged`) - use only if a build/update hook must replace lazy-managed install behavior.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('nvim-treesitter.configs')" +qa` exits `0`.
  - [ ] `grep -RInE 'event\s*=|opts\s*=|config\s*=' /home/chandler/repos/dotfiles/nvim/lua/treesitter.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/autotag.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/render-markdown.lua` returns no leftover lazy-spec fields.

  **QA Scenarios**:
  ```text
  Scenario: Treesitter config is require-safe after eager migration
    Tool: Bash
    Preconditions: Tasks 1, 2, and 5 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('nvim-treesitter.configs')" +qa > .sisyphus/evidence/task-5-treesitter.txt 2>&1`.
      2. Confirm exit code 0 and no parser-config Lua errors.
    Expected Result: treesitter config loads under the new bootstrap.
    Failure Indicators: module-not-found, bad dependency order, or runtime error.
    Evidence: .sisyphus/evidence/task-5-treesitter.txt

  Scenario: Lazy-spec fields are fully removed from markup helpers
    Tool: Bash
    Preconditions: Tasks 1, 2, and 5 complete.
    Steps:
      1. Run `grep -RInE 'event\s*=|opts\s*=|config\s*=' /home/chandler/repos/dotfiles/nvim/lua/treesitter.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/autotag.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/render-markdown.lua > .sisyphus/evidence/task-5-markup-grep.txt 2>&1`.
      2. Confirm exit code 1 and empty evidence file.
    Expected Result: these files no longer depend on lazy spec semantics.
    Failure Indicators: any matched field in the evidence file.
    Evidence: .sisyphus/evidence/task-5-markup-grep.txt
  ```

  **Commit**: NO

- [x] 6. Convert formatting, lint, and autopairs hooks

  **What to do**:
  - Translate `lua/plugins/conform.lua`, `lua/plugins/lint.lua`, and `lua/plugins/autopairs.lua` to explicit eager setup.
  - Replace lazy event/cmd/key registration with direct autocommands and keymaps where needed.
  - Preserve `ConformInfo`, format-on-save, lint-on-write, and autopairs behavior.

  **Must NOT do**:
  - Do not broaden formatter/linter coverage.
  - Do not remove existing format/lint triggers without explicit eager replacements.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` - behavior must survive event-gate removal cleanly.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 10, 11
  - **Blocked By**: 1

  **References**:
  - `lua/plugins/conform.lua:1` - lazy `event`, `cmd`, `keys`, and `opts` fields to replace explicitly.
  - `lua/plugins/lint.lua` - current lint triggers and dependency pattern.
  - `lua/plugins/autopairs.lua` - current autopairs load/setup pattern.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('conform')" +qa` exits `0`.
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('lint')" +qa` exits `0`.
  - [ ] `grep -RInE 'event\s*=|cmd\s*=|keys\s*=|opts\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/conform.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lint.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/autopairs.lua` returns no leftover lazy-spec fields.

  **QA Scenarios**:
  ```text
  Scenario: Formatting stack loads without lazy indirection
    Tool: Bash
    Preconditions: Tasks 1, 2, and 6 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('conform')" +qa > .sisyphus/evidence/task-6-conform.txt 2>&1`.
      2. Confirm exit code 0 and no setup error.
    Expected Result: `conform` is available eagerly.
    Failure Indicators: module-not-found or setup failure.
    Evidence: .sisyphus/evidence/task-6-conform.txt

  Scenario: Lint/autopairs files no longer carry lazy gates
    Tool: Bash
    Preconditions: Tasks 1, 2, and 6 complete.
    Steps:
      1. Run `grep -RInE 'event\s*=|cmd\s*=|keys\s*=|opts\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/conform.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lint.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/autopairs.lua > .sisyphus/evidence/task-6-hooks-grep.txt 2>&1`.
      2. Confirm exit code 1 and empty evidence file.
    Expected Result: lazy fields are replaced with explicit eager hooks.
    Failure Indicators: any matched lazy field in evidence.
    Evidence: .sisyphus/evidence/task-6-hooks-grep.txt
  ```

  **Commit**: NO

- [x] 7. Convert search and picker stack

  **What to do**:
  - Translate `lua/plugins/snacks.lua` and `lua/plugins/telescope.lua` to eager-loading setup.
  - Preserve current keymaps, picker behavior, and any required dependency ordering.
  - Replace any lazy event/build/cond semantics with explicit eager alternatives or documented `PackChanged` handling where truly required.

  **Must NOT do**:
  - Do not redesign picker UX or key layout.
  - Do not silently drop optional extensions that were previously active.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` - high-coupling UI/search modules with many keymaps and dependencies.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: F1, F2, F3, F4
  - **Blocked By**: 2, 5

  **References**:
  - `lua/plugins/snacks.lua:1` - large eager plugin candidate already marked `lazy = false`, but still encoded as a lazy spec.
  - `lua/plugins/telescope.lua:1` - current `event`, `dependencies`, `build`, and `config` semantics to translate.
  - `lua/plugins/nvim-lspconfig.lua:70` - telescope builtins are consumed by LSP keymaps and must remain available.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('snacks')" +qa` exits `0`.
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('telescope')" +qa` exits `0`.

  **QA Scenarios**:
  ```text
  Scenario: Search stack loads eagerly without missing dependencies
    Tool: Bash
    Preconditions: Tasks 1, 2, 5, and 7 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('snacks'); require('telescope')" +qa > .sisyphus/evidence/task-7-search-stack.txt 2>&1`.
      2. Confirm exit code 0 and no missing dependency/build-hook errors.
    Expected Result: both search stacks require successfully under eager startup.
    Failure Indicators: Lua errors mentioning missing plugins, missing `make` build output, or bad load order.
    Evidence: .sisyphus/evidence/task-7-search-stack.txt

  Scenario: No stale lazy fields remain in search modules
    Tool: Bash
    Preconditions: Task 7 complete.
    Steps:
      1. Run `grep -RInE 'event\s*=|dependencies\s*=|build\s*=|config\s*=|lazy\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/snacks.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/telescope.lua > .sisyphus/evidence/task-7-search-grep.txt 2>&1`.
      2. Confirm exit code 1 and empty evidence file.
    Expected Result: search modules are no longer lazy specs.
    Failure Indicators: matched lazy-spec fields in evidence.
    Evidence: .sisyphus/evidence/task-7-search-grep.txt
  ```

  **Commit**: NO

- [x] 8. Convert status, window, and notification UI stack

  **What to do**:
  - Translate `lua/plugins/bufferline.lua`, `lua/plugins/lualine.lua`, and `lua/plugins/noice.lua` to eager-loading setup.
  - Preserve statusline, tabline, and notification behavior without `event`/`opts` indirection.
  - Ensure dependency order is explicit where UI plugins depend on each other or on icon providers.

  **Must NOT do**:
  - Do not re-theme or restyle the UI.
  - Do not move UI keymaps into unrelated files.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` - interdependent UI modules with subtle startup-order requirements.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: F1, F2, F3, F4
  - **Blocked By**: 2, 4

  **References**:
  - `lua/plugins/bufferline.lua` - tabline dependency/setup pattern.
  - `lua/plugins/lualine.lua` - statusline config currently wrapped in lazy semantics.
  - `lua/plugins/noice.lua` - event-driven notification/UI config to translate.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('bufferline'); require('lualine'); require('noice')" +qa` exits `0`.
  - [ ] `grep -RInE 'event\s*=|opts\s*=|config\s*=|dependencies\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/bufferline.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lualine.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/noice.lua` returns no leftover lazy-spec fields.

  **QA Scenarios**:
  ```text
  Scenario: UI stack requires cleanly under eager startup
    Tool: Bash
    Preconditions: Tasks 1, 2, 4, and 8 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('bufferline'); require('lualine'); require('noice')" +qa > .sisyphus/evidence/task-8-ui-stack.txt 2>&1`.
      2. Confirm exit code 0 with no dependency-order errors.
    Expected Result: all three UI modules require successfully.
    Failure Indicators: module-not-found or load-order errors in evidence.
    Evidence: .sisyphus/evidence/task-8-ui-stack.txt

  Scenario: UI files no longer contain lazy-spec keys
    Tool: Bash
    Preconditions: Task 8 complete.
    Steps:
      1. Run `grep -RInE 'event\s*=|opts\s*=|config\s*=|dependencies\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/bufferline.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lualine.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/noice.lua > .sisyphus/evidence/task-8-ui-grep.txt 2>&1`.
      2. Confirm exit code 1 and empty evidence file.
    Expected Result: lazy fields are fully removed from these UI modules.
    Failure Indicators: any matched line in evidence.
    Evidence: .sisyphus/evidence/task-8-ui-grep.txt
  ```

  **Commit**: NO

- [x] 9. Convert completion and dev-experience stack

  **What to do**:
  - Translate `lua/plugins/blink.lua`, `lua/plugins/lazydev.lua`, and `lua/plugins/mini.lua` to direct eager setup.
  - Preserve completion, Lua development helpers, snippets, and mini-module behavior.
  - Make dependency ordering explicit for `blink.cmp`, `LuaSnip`, and `lazydev`.

  **Must NOT do**:
  - Do not replace completion/snippet engines.
  - Do not drop build steps that are still required for current functionality.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` - dependency-heavy completion stack with build/version considerations.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: 10, F1, F2, F3, F4
  - **Blocked By**: 2, 4

  **References**:
  - `lua/plugins/blink.lua:1` - current `event`, `version`, `dependencies`, `build`, and `opts` semantics to replace explicitly.
  - `lua/plugins/lazydev.lua` - lazydev filetype-gated setup that must become eager-safe.
  - `lua/plugins/mini.lua` - mini module setup currently wrapped as a lazy spec.
  - `lua/plugins/nvim-lspconfig.lua:195` - blink capabilities are consumed by the LSP stack and must remain compatible.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('blink.cmp'); require('lazydev')" +qa` exits `0`.
  - [ ] `grep -RInE 'event\s*=|ft\s*=|dependencies\s*=|build\s*=|opts\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/blink.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lazydev.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/mini.lua` returns no leftover lazy-spec fields.

  **QA Scenarios**:
  ```text
  Scenario: Completion/dev stack loads after eager conversion
    Tool: Bash
    Preconditions: Tasks 1, 2, 4, and 9 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('blink.cmp'); require('lazydev')" +qa > .sisyphus/evidence/task-9-completion.txt 2>&1`.
      2. Confirm exit code 0 and no dependency/build errors.
    Expected Result: completion and dev helpers require successfully.
    Failure Indicators: missing module, failed build hook, or bad load order.
    Evidence: .sisyphus/evidence/task-9-completion.txt

  Scenario: Completion/dev files are free of lazy-spec fields
    Tool: Bash
    Preconditions: Task 9 complete.
    Steps:
      1. Run `grep -RInE 'event\s*=|ft\s*=|dependencies\s*=|build\s*=|opts\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/blink.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lazydev.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/mini.lua > .sisyphus/evidence/task-9-completion-grep.txt 2>&1`.
      2. Confirm exit code 1 and empty evidence file.
    Expected Result: files no longer depend on lazy.nvim semantics.
    Failure Indicators: any matched field in evidence.
    Evidence: .sisyphus/evidence/task-9-completion-grep.txt
  ```

  **Commit**: NO

- [x] 10. Convert LSP and health/version integration

  **What to do**:
  - Translate `lua/plugins/nvim-lspconfig.lua` and `lua/plugins/lsp-colors.lua` to explicit eager setup with correct package order.
  - Update `lua/health.lua` to reflect the Neovim `0.12` target and remove stale kickstart-era version assumptions.
  - Preserve Mason/tool installer behavior only if still supported cleanly under `vim.pack`; otherwise replace with explicit startup-safe setup that matches current behavior as closely as possible.

  **Must NOT do**:
  - Do not remove LSP keymaps, diagnostics, or capability wiring.
  - Do not silently omit tool-install/build behavior that current config depends on.

  **Recommended Agent Profile**:
  - **Category**: `deep` - highest coupling area, with capabilities, dependencies, autocommands, and runtime validation.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: F1, F2, F3, F4
  - **Blocked By**: 2, 5, 6, 9

  **References**:
  - `lua/plugins/nvim-lspconfig.lua:4` - dependency chain for mason, tool installer, fidget, and blink.
  - `lua/plugins/nvim-lspconfig.lua:48` - `LspAttach` autocommand behavior that must survive the migration.
  - `lua/plugins/nvim-lspconfig.lua:195` - blink capability integration point.
  - `lua/health.lua:15` - stale `0.10-dev` version logic to replace with `0.12`-appropriate checks.
  - `lua/startup-validation.lua:5` - related version-floor behavior already updated in Task 1.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('lspconfig'); print('OK_LSP')" +qa` prints `OK_LSP`.
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+checkhealth kickstart.nvim" +qa` exits `0`.
  - [ ] `grep -RInE 'dependencies\s*=|config\s*=|opts\s*=|event\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/nvim-lspconfig.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lsp-colors.lua` returns no leftover lazy-spec fields.

  **QA Scenarios**:
  ```text
  Scenario: LSP stack boots with blink capabilities intact
    Tool: Bash
    Preconditions: Tasks 1, 2, 5, 6, 9, and 10 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('lspconfig'); print(require('blink.cmp').get_lsp_capabilities() and 'OK_LSP_CAPS' or 'BAD_LSP_CAPS')" +qa > .sisyphus/evidence/task-10-lsp.txt 2>&1`.
      2. Confirm output contains `OK_LSP_CAPS`.
    Expected Result: LSP config and blink capability integration both load successfully.
    Failure Indicators: missing module, nil capabilities, or Lua error.
    Evidence: .sisyphus/evidence/task-10-lsp.txt

  Scenario: Health check reflects the migrated config cleanly
    Tool: Bash
    Preconditions: Tasks 1, 2, and 10 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+checkhealth kickstart.nvim" +qa > .sisyphus/evidence/task-10-health.txt 2>&1`.
      2. Confirm exit code 0 and no new migration-induced errors in the output.
    Expected Result: health checks remain green after the migration.
    Failure Indicators: non-zero exit, startup error, or stale version warnings caused by migration.
    Evidence: .sisyphus/evidence/task-10-health.txt
  ```

  **Commit**: YES
  - Message: `refactor(plugins): port lsp stack to eager vim.pack setup`
  - Files: `lua/plugins/nvim-lspconfig.lua`, `lua/plugins/lsp-colors.lua`, `lua/health.lua`

- [x] 11. Convert diagnostics, git, and debug tooling

  **What to do**:
  - Translate `lua/plugins/trouble.lua`, `lua/plugins/gitsigns.lua`, `lua/plugins/debug.lua`, and `lua/plugins/todo-comments.lua` to explicit eager setup.
  - Preserve diagnostics views, git signs, TODO surfaces, and debug keypaths/commands.
  - Ensure dependencies are installed and required in explicit order rather than via lazy specs.

  **Must NOT do**:
  - Do not redesign keymaps or debug adapters.
  - Do not remove git/debug tooling just because it is not always-on.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` - mixed dependency and command-surface migration.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: F1, F2, F3, F4
  - **Blocked By**: 2, 6

  **References**:
  - `lua/plugins/trouble.lua` - command/key-oriented diagnostics UI currently in lazy form.
  - `lua/plugins/gitsigns.lua` - git integration currently encoded as nested lazy spec list.
  - `lua/plugins/debug.lua` - debug plugin/dependency ordering and setup.
  - `lua/plugins/todo-comments.lua` - active comments/todo surfacing plugin that must not be omitted from the migration.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('trouble'); require('gitsigns'); require('todo-comments')" +qa` exits `0`.
  - [ ] `grep -RInE 'cmd\s*=|keys\s*=|dependencies\s*=|opts\s*=|config\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/trouble.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/gitsigns.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/debug.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/todo-comments.lua` returns no leftover lazy-spec fields.

  **QA Scenarios**:
  ```text
  Scenario: Diagnostics and git tooling require cleanly
    Tool: Bash
    Preconditions: Tasks 1, 2, 6, and 11 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('trouble'); require('gitsigns'); require('todo-comments')" +qa > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/task-11-diagnostics.txt 2>&1`.
      2. Confirm exit code 0 and no setup errors.
    Expected Result: diagnostics, git tooling, and TODO comments are available under eager startup.
    Failure Indicators: module-not-found or dependency-order errors.
    Evidence: .sisyphus/evidence/task-11-diagnostics.txt

  Scenario: Debug/git files are free of lazy-spec keys
    Tool: Bash
    Preconditions: Task 11 complete.
    Steps:
      1. Run `grep -RInE 'cmd\s*=|keys\s*=|dependencies\s*=|opts\s*=|config\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/trouble.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/gitsigns.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/debug.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/todo-comments.lua > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/task-11-debug-grep.txt 2>&1`.
      2. Confirm exit code 1 and empty evidence file.
    Expected Result: these modules no longer use lazy-spec wiring.
    Failure Indicators: any matched field in evidence.
    Evidence: .sisyphus/evidence/task-11-debug-grep.txt
  ```

  **Commit**: NO

- [x] 12. Convert remaining active helpers and devcontainer integration

  **What to do**:
  - Translate `lua/plugins/flash.lua`, `lua/plugins/vim-matchup.lua`, `lua/plugins/vim-tmux-navigator.lua`, and `lua/plugins/nvim-dev-container.lua` to direct eager setup.
  - Preserve navigation, text-object, tmux, and devcontainer behavior where currently active.
  - Explicitly leave dormant commented-out modules (`copilot`, `lazygit`, `minimap`, `neorg`) untouched unless they block the migration, but verify they are not still referenced by the active bootstrap path.

  **Must NOT do**:
  - Do not enable dormant modules.
  - Do not treat commented examples as active migration targets unless they are still wired in.

  **Recommended Agent Profile**:
  - **Category**: `quick` - final low-level cleanup and active-module parity work.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: F1, F2, F3, F4
  - **Blocked By**: 2

  **References**:
  - `lua/plugins/flash.lua` - key/event-gated navigation helper.
  - `lua/plugins/vim-matchup.lua` - matchup config currently expressed as lazy spec.
  - `lua/plugins/vim-tmux-navigator.lua` - command/key-based tmux navigation helper.
  - `lua/plugins/nvim-dev-container.lua` - active devcontainer integration to keep loading cleanly.
  - `lua/plugins/init.lua:11` - dormant `copilot` module remains commented out and should stay inactive.
  - `lua/plugins/init.lua:13` - dormant `lazygit` module remains commented out and should stay inactive.
  - `lua/plugins/init.lua:19` - dormant `minimap` module remains commented out and should stay inactive.

  **Acceptance Criteria**:
  - [ ] `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('flash'); print('OK_HELPERS')" +qa` prints `OK_HELPERS`.
  - [ ] `grep -RInE 'event\s*=|cmd\s*=|keys\s*=|lazy\s*=|dependencies\s*=|opts\s*=|config\s*=' /home/chandler/repos/dotfiles/nvim/lua/plugins/flash.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/vim-matchup.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/vim-tmux-navigator.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/nvim-dev-container.lua` returns no leftover lazy-spec fields.

  **QA Scenarios**:
  ```text
  Scenario: Remaining helpers load without lazy wiring
    Tool: Bash
    Preconditions: Tasks 1, 2, and 12 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('flash'); print('OK_HELPERS')" +qa > .sisyphus/evidence/task-12-helpers.txt 2>&1`.
      2. Confirm output contains `OK_HELPERS`.
    Expected Result: remaining helper stack loads under eager startup.
    Failure Indicators: module-not-found or setup error.
    Evidence: .sisyphus/evidence/task-12-helpers.txt

  Scenario: Dormant lazy-era modules are not active migration dependencies
    Tool: Bash
    Preconditions: Task 12 complete.
    Steps:
      1. Run `grep -nE '^[[:space:]]*require\(("|\x27)plugins\.(copilot|lazygit|minimap|neorg)' /home/chandler/repos/dotfiles/nvim/lua/plugins/init.lua > .sisyphus/evidence/task-12-dormant-grep.txt 2>&1`.
      2. Confirm the command exits 1 and the evidence file is empty.
    Expected Result: dormant modules stay out of the active bootstrap path.
    Failure Indicators: any uncommented active `require(...)` line for a dormant module.
    Evidence: .sisyphus/evidence/task-12-dormant-grep.txt
  ```

  **Commit**: YES
  - Message: `refactor(plugins): finish eager vim.pack migration`
  - Files: `lua/plugins/flash.lua`, `lua/plugins/vim-matchup.lua`, `lua/plugins/vim-tmux-navigator.lua`, `lua/plugins/nvim-dev-container.lua`

---

## Final Verification Wave

- [x] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. Verify every bootstrap, plugin-module, docs, and artifact deliverable exists. Confirm no forbidden lazy-specific tokens remain in active config files. Output `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT`.

  **QA Scenarios**:
  ```text
  Scenario: Compliance audit produces a concrete verdict
    Tool: Bash
    Preconditions: Tasks 1-12 complete.
    Steps:
      1. Run `grep -RInE 'require\("lazy"\)|lazy.nvim|LazyVimStarted|VeryLazy|:Lazy|lazy-lock.json' /home/chandler/repos/dotfiles/nvim --exclude-dir=.sisyphus > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f1-compliance-grep.txt 2>&1`.
      2. Confirm the command exits 1 and the evidence file is empty.
      3. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless +qa > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f1-headless.txt 2>&1`.
      4. Confirm exit code 0.
    Expected Result: forbidden lazy-era tokens are absent and headless startup succeeds.
    Failure Indicators: any grep match or startup error.
    Evidence: /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f1-compliance-grep.txt
  ```

- [x] F2. **Code Quality Review** — `unspecified-high`
  Run headless startup, grep checks, and any repo linting/formatting commands already available. Review changed Lua files for leftover lazy keys, dead comments, brittle ordering, and generated-file mistakes. Output `Startup [PASS/FAIL] | Grep [PASS/FAIL] | Files [N clean/N issues] | VERDICT`.

  **QA Scenarios**:
  ```text
  Scenario: Code quality sweep catches leftover lazy-spec fields
    Tool: Bash
    Preconditions: Tasks 1-12 complete.
    Steps:
      1. Run `grep -RInE '\b(event|cmd|ft|keys|lazy|dependencies|opts|config)\s*=' /home/chandler/repos/dotfiles/nvim/lua/colorscheme.lua /home/chandler/repos/dotfiles/nvim/lua/treesitter.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/which-key.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/autotag.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/render-markdown.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/conform.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lint.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/autopairs.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/snacks.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/telescope.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/bufferline.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lualine.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/noice.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/blink.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lazydev.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/mini.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/nvim-lspconfig.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/lsp-colors.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/trouble.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/gitsigns.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/debug.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/todo-comments.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/flash.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/vim-matchup.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/vim-tmux-navigator.lua /home/chandler/repos/dotfiles/nvim/lua/plugins/nvim-dev-container.lua > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f2-lazy-fields.txt 2>&1`.
      2. Confirm the command exits 1 and the evidence file is empty.
      3. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+checkhealth kickstart.nvim" +qa > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f2-health.txt 2>&1`.
      4. Confirm exit code 0.
    Expected Result: no leftover lazy-spec fields remain in migrated plugin files and health checks pass.
    Failure Indicators: leftover spec fields in migrated modules or non-zero health check.
    Evidence: /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f2-lazy-fields.txt
  ```

- [x] F3. **Real Executable QA** — `unspecified-high`
  Execute every task QA scenario with `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles`. Save command output to `.sisyphus/evidence/final-qa/`. Output `Scenarios [N/N pass] | Integration [N/N] | Edge Cases [N tested] | VERDICT`.

  **QA Scenarios**:
  ```text
  Scenario: Representative plugin stack boots together under final config
    Tool: Bash
    Preconditions: Tasks 1-12 complete.
    Steps:
      1. Run `XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua require('snacks'); require('telescope'); require('blink.cmp'); require('lspconfig'); require('gitsigns'); print('OK_FINAL_STACK')" +qa > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f3-stack.txt 2>&1`.
      2. Confirm output contains `OK_FINAL_STACK`.
    Expected Result: representative high-coupling plugin stack loads together.
    Failure Indicators: any module load error or missing `OK_FINAL_STACK` marker.
    Evidence: /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f3-stack.txt
  ```

- [x] F4. **Scope Fidelity Check** — `deep`
  Compare the actual diff against this plan. Reject any compatibility shim, CI/test-framework addition, plugin additions, or unrelated refactors. Output `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | Unaccounted [CLEAN/N files] | VERDICT`.

  **QA Scenarios**:
  ```text
  Scenario: Scope guardrails hold in final diff
    Tool: Bash
    Preconditions: Tasks 1-12 complete.
    Steps:
      1. Run `grep -RInE 'compat|adapter|shim|plenary\.test_harness|github/workflows' /home/chandler/repos/dotfiles/nvim --exclude-dir=.git --exclude-dir=.sisyphus > /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f4-scope-grep.txt 2>&1`.
      2. Confirm the command exits 1 and the evidence file is empty.
    Expected Result: no forbidden scope-creep artifacts were introduced.
    Failure Indicators: new compatibility layer code, CI workflows, or test-framework scaffolding introduced by the migration.
    Evidence: /home/chandler/repos/dotfiles/nvim/.sisyphus/evidence/final-qa/f4-scope-grep.txt
  ```

---

## Commit Strategy

- **1**: `refactor(nvim): switch bootstrap to vim.pack`
- **2**: `refactor(plugins): port eager plugin setup to vim.pack`
- **3**: `docs(nvim): remove lazy.nvim references`

---

## Success Criteria

### Verification Commands
```bash
grep -RInE 'require\("lazy"\)|lazy.nvim|LazyVimStarted|VeryLazy|:Lazy|lazy-lock.json' /home/chandler/repos/dotfiles/nvim --exclude-dir=.sisyphus
XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+lua print(vim.fn.has('nvim-0.12') == 1 and 'OK_NVIM_012' or 'BAD_NVIM_VERSION')" +qa
XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless +qa
XDG_CONFIG_HOME=/home/chandler/repos/dotfiles nvim --headless "+checkhealth kickstart.nvim" +qa
```

### Final Checklist
- [ ] All active lazy-specific bootstrap/runtime references removed
- [ ] `vim.pack` owns package installation path and lockfile behavior
- [ ] Active plugins still initialize under eager loading
- [ ] Headless startup and health checks pass on Neovim `0.12`
