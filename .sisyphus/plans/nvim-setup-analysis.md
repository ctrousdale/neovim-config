# Neovim Configuration Consolidation

## TL;DR
> **Summary**: Refactor the Neovim config into a single modern plugin-registration model, remove overlapping providers, tighten keymap ownership, and add lightweight headless smoke validation for `Neovim 0.11+`.
> **Deliverables**:
> - single-source plugin architecture under `lua/plugins/`
> - consolidated provider choices for search/LSP UI, statusline, navigation, and formatting
> - corrected keymap/which-key/runtime behavior with smoke checks
> - reduced dead config and smaller, easier-to-maintain hotspot modules
> **Effort**: Large
> **Parallel**: YES - 3 waves
> **Critical Path**: 1 -> 2 -> 4 -> 6 -> 8

## Context
### Original Request
Analyze the Neovim setup for improvements, prioritizing clean, properly-written, modern code and architecture, while ensuring the keybinds and general Neovim best practices are sensible.

### Interview Summary
- User wants an opinionated cleanup, not a conservative preservation pass.
- Target baseline is `Neovim 0.11+`.
- Add minimal automated smoke checks instead of a full test harness.
- Optimize for maintainability, sensible UX, and explicit ownership boundaries.

### Metis Review (gaps addressed)
- Lock single owners per capability before refactoring.
- Treat keymaps as a public API and preserve UX contracts during migration.
- Exclude feature expansion and broad preference churn.
- Add repeatable headless checks for startup, key ownership, and optional-executable handling.

## Work Objectives
### Core Objective
Convert the current hybrid, overlap-heavy Neovim config into a decision-consistent `0.11+` configuration with one clear owner per capability and a repeatable validation path.

### Deliverables
- Modernized plugin registration centered on `lua/plugins/`
- Provider consolidation decisions implemented as code:
  - search/picker/LSP fuzzy UI owner: `folke/snacks.nvim`
  - statusline owner: `echasnovski/mini.nvim` (`mini.statusline`)
  - split/tmux navigation owner: `christoomey/vim-tmux-navigator`
  - formatting authority: `stevearc/conform.nvim` with explicit LSP fallback via Conform only
  - key-discovery owner: `folke/which-key.nvim`
- Dead/unregistered plugin config removed
- Hotspot modules split so plugin spec, keymaps, and behavior are no longer mixed in one large file where practical
- Headless smoke validation entrypoint with evidence-friendly commands

### Definition of Done (verifiable conditions with commands)
- `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` exits `0`
- `nvim --headless -u init.lua "+checkhealth" +qa` reports `0.11+` consistently across custom health/startup checks
- `nvim --headless -u init.lua "+lua require('smoke').assert_keymap_policy()" +qa` confirms no duplicate ownership for declared protected mappings
- `nvim --headless -u init.lua "+lua require('smoke').assert_provider_policy()" +qa` confirms only the chosen providers remain active for search/LSP UI/statusline

### Must Have
- One plugin registration pattern
- One owner per capability
- No unresolved keymap collisions in protected namespaces (`<C-h/j/k/l>`, `<leader>/`, `<leader>s*`, core LSP navigation keys)
- Matching version policy between startup validation and health reporting
- Dependency-light smoke checks with explicit warn/skip behavior for missing external binaries

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- No new feature work unrelated to consolidation
- No parallel ownership of the same capability after the refactor
- No full-blown CI/test framework rollout
- No aesthetic/options churn unless directly needed for architecture or runtime correctness
- No migration that silently breaks common workflows without either preserving the binding or documenting a deliberate replacement in code comments/help text

## Verification Strategy
> ZERO HUMAN INTERVENTION - all verification is agent-executed.
- Test decision: `tests-after` using a minimal custom headless smoke module plus `:checkhealth`
- QA policy: Every task includes agent-executed happy-path and failure/edge scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: validation foundation, plugin-registry normalization, runtime/version policy
Wave 2: dead-config cleanup, provider consolidation, statusline/key-discovery cleanup
Wave 3: navigation/keymap policy, hotspot-module decomposition

### Dependency Matrix (full, all tasks)
- `1` blocks `4`, `5`, `6`, `7`, `8`
- `2` blocks `3`, `4`, `5`, `8`
- `3` blocked by `2`; does not block `7`
- `4` blocked by `1`, `2`; blocks `6`, `8`
- `5` blocked by `1`, `2`; can run with `4`
- `6` blocked by `1`, `4`, `5`
- `7` blocked by `1`; can run with `2`
- `8` blocked by `2`, `4`, `6`, `7`

### Agent Dispatch Summary (wave -> task count -> categories)
- Wave 1 -> 3 tasks -> `code`, `deep`
- Wave 2 -> 3 tasks -> `code`, `quick`
- Wave 3 -> 2 tasks -> `code`, `deep`

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. Add headless smoke validation and policy assertions

  **What to do**: Create a minimal smoke module for this config, exposed via `require('smoke').run()`, plus focused helpers such as `assert_keymap_policy()` and `assert_provider_policy()`. The smoke entrypoint must boot the config under `init.lua`, verify startup validation does not throw, confirm declared provider choices remain true, and treat missing optional executables as explicit warnings/skips rather than opaque failures.
  **Must NOT do**: Do not add a general-purpose Lua test framework, CI pipeline, or broad snapshot testing.

  **Recommended Agent Profile**:
  - Category: `code` - Reason: requires small runtime helpers and executable validation commands.
  - Skills: `[]` - no special skill is required beyond direct code changes.
  - Omitted: `playwright` - no browser/UI automation is needed.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: `4`, `5`, `6`, `7`, `8` | Blocked By: none

  **References**:
  - Pattern: `init.lua:10` - existing startup validation entrypoint the smoke module must exercise.
  - Pattern: `lua/startup-validation.lua:3` - current runtime policy hook to validate without crashing startup.
  - Pattern: `lua/health.lua:37` - current custom health reporting entrypoint to keep aligned with smoke expectations.
  - Pattern: `lua/keymaps.lua:29` - protected key namespace currently defined globally and worth asserting.

  **Acceptance Criteria**:
  - [ ] `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` exits `0` on a supported environment.
  - [ ] `nvim --headless -u init.lua "+lua require('smoke').assert_keymap_policy()" +qa` fails if duplicate owners still exist for the protected mapping set and passes once the consolidation is complete.
  - [ ] `nvim --headless -u init.lua "+lua require('smoke').assert_provider_policy()" +qa` verifies the chosen owners for search/LSP UI/statusline.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Headless config boot succeeds
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` from the repo root.
    Expected: Process exits 0 and writes a success log to `.sisyphus/evidence/task-1-smoke-validation.txt`.
    Evidence: .sisyphus/evidence/task-1-smoke-validation.txt

  Scenario: Missing optional executable degrades cleanly
    Tool: Bash
    Steps: Run the same smoke entrypoint in an environment where one optional binary used by lint/format checks is intentionally absent or masked.
    Expected: Smoke run exits 0, emits a clear warning/skip note, and writes that result to `.sisyphus/evidence/task-1-smoke-validation-error.txt`.
    Evidence: .sisyphus/evidence/task-1-smoke-validation-error.txt
  ```

  **Commit**: YES | Message: `test(nvim): add smoke validation entrypoint` | Files: `init.lua`, `lua/smoke.lua`, any minimal helper file needed for assertions

- [x] 2. Normalize plugin registration to one modern import model

  **What to do**: Replace the current hybrid plugin-registration approach with one canonical lazy.nvim import flow rooted at `lua/plugins/`. Move top-level plugin specs such as `lua/colorscheme.lua` and `lua/treesitter.lua` into `lua/plugins/`, eliminate the extra registry layer in `lua/plugins/init.lua`, and make `lua/lazy-plugins.lua` the only bootstrap/spec entrypoint.
  **Must NOT do**: Do not change plugin behavior yet beyond what is required to preserve loading under the new registration model.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: touches repo-wide architecture, load order, and future maintainability.
  - Skills: `[]` - direct file edits are sufficient.
  - Omitted: `git-master` - no git operation is part of this task itself.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: `3`, `4`, `5`, `8` | Blocked By: none

  **References**:
  - Pattern: `lua/lazy-plugins.lua:12` - current `require("lazy").setup` root to convert into a single import model.
  - Pattern: `lua/lazy-plugins.lua:39` - direct require of `plugins.which-key` currently mixed with other registration styles.
  - Pattern: `lua/lazy-plugins.lua:43` - nested plugin registry import that should be retired.
  - Pattern: `lua/lazy-plugins.lua:54` - top-level colorscheme spec currently outside `lua/plugins/`.
  - Pattern: `lua/lazy-plugins.lua:56` - top-level treesitter spec currently outside `lua/plugins/`.
  - Pattern: `lua/plugins/init.lua:5` - extra registry layer to remove once `lazy.nvim` imports directly from `lua/plugins/`.
  - Pattern: `lua/AGENTS.md:15` - repo guidance already prefers plugin config under `lua/plugins/`.

  **Acceptance Criteria**:
  - [ ] `lua/lazy-plugins.lua` is the only plugin-registration entrypoint.
  - [ ] All plugin specs load from `lua/plugins/` via a single lazy import pattern.
  - [ ] `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` still exits `0` after the registry migration.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Plugin import model boots cleanly
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` after moving specs and changing lazy import wiring.
    Expected: No module-not-found errors; output confirms plugin registration completed.
    Evidence: .sisyphus/evidence/task-2-plugin-imports.txt

  Scenario: Missing moved module is caught immediately
    Tool: Bash
    Steps: Run the smoke command after intentionally verifying that stale `require('colorscheme')`/`require('treesitter')` references are gone.
    Expected: The command would fail if old references remained; final state passes with no stale top-level requires.
    Evidence: .sisyphus/evidence/task-2-plugin-imports-error.txt
  ```

  **Commit**: YES | Message: `refactor(nvim): normalize plugin registration` | Files: `lua/lazy-plugins.lua`, `lua/plugins/init.lua`, `lua/colorscheme.lua`, `lua/treesitter.lua`, new files under `lua/plugins/`

- [x] 3. Remove dormant plugin configs and stale scaffold drift

  **What to do**: Delete unregistered or deliberately abandoned plugin config files and clean out stale Kickstart/comment scaffolding that obscures the active architecture. Remove configs only after task 2 lands so the active registry is authoritative first.
  **Must NOT do**: Do not delete any plugin that still owns an approved capability after the provider decisions in this plan.

  **Recommended Agent Profile**:
  - Category: `quick` - Reason: mostly targeted cleanup once architecture ownership is settled.
  - Skills: `[]` - simple repo maintenance work.
  - Omitted: `refactor` - not needed for straightforward file removal and comment cleanup.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: none | Blocked By: `2`

  **References**:
  - Pattern: `lua/plugins/init.lua:11` - commented-out `copilot` reference showing current drift.
  - Pattern: `lua/plugins/init.lua:13` - commented-out `lazygit` reference, while Snacks already owns lazygit access.
  - Pattern: `lua/plugins/init.lua:19` - commented-out `minimap` reference.
  - Pattern: `lua/lazy-plugins.lua:57` - stale Kickstart scaffolding and comments no longer aligned to the repo.
  - Pattern: `lua/plugins/snacks.lua:469` - active `Snacks.lazygit()` entrypoint that makes separate lazygit config redundant.

  **Acceptance Criteria**:
  - [ ] Unregistered plugin config files that are not part of the chosen architecture are removed.
  - [ ] Stale scaffold comments no longer misdescribe the repo's active plugin architecture.
  - [ ] Smoke validation still passes after cleanup.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Dead config cleanup keeps active setup bootable
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` after deleting dormant config files and stale references.
    Expected: Exit 0 with no missing-module or missing-command errors.
    Evidence: .sisyphus/evidence/task-3-dead-config-cleanup.txt

  Scenario: Removed module no longer appears in active registry
    Tool: Bash
    Steps: Run a repo check such as `git diff --name-status` plus the smoke entrypoint to verify the intended dormant files are deleted and no active require path references them.
    Expected: Only planned dormant modules are removed; boot remains clean.
    Evidence: .sisyphus/evidence/task-3-dead-config-cleanup-error.txt
  ```

  **Commit**: YES | Message: `chore(nvim): remove dormant plugin configs` | Files: dormant files under `lua/plugins/`, cleaned scaffold comments in `lua/lazy-plugins.lua`

- [x] 4. Consolidate picker and LSP fuzzy UI on Snacks

  **What to do**: Make `folke/snacks.nvim` the single owner for fuzzy search, picker UI, and picker-based LSP navigation. Remove `nvim-telescope/telescope.nvim` and its extension wiring, migrate the surviving search workflows to Snacks mappings, and update LSP-related fuzzy navigation in `lua/plugins/nvim-lspconfig.lua` to stop depending on Telescope.
  **Must NOT do**: Do not change the chosen user-facing workflows beyond consolidating them onto Snacks; keep sensible equivalents for current file search, grep, buffers, help, diagnostics, and LSP symbol/reference flows.

  **Recommended Agent Profile**:
  - Category: `code` - Reason: implementation is concrete but touches multiple interdependent modules.
  - Skills: `[]` - the work is repo-local and pattern-driven.
  - Omitted: `artistry` - this is architectural consolidation, not open-ended invention.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: `6`, `8` | Blocked By: `1`, `2`

  **References**:
  - Pattern: `lua/plugins/snacks.lua:44` - Snacks already owns a broad picker/keymap surface and should become the single source of truth.
  - Pattern: `lua/plugins/snacks.lua:359` - existing Snacks LSP picker bindings that can replace Telescope-backed fuzzy LSP maps.
  - Pattern: `lua/plugins/telescope.lua:24` - Telescope setup block to remove after equivalent Snacks ownership is preserved.
  - Pattern: `lua/plugins/telescope.lua:69` - current `<leader>s*` namespace overlap to collapse.
  - Pattern: `lua/plugins/telescope.lua:82` - overlapping `<leader>/` current-buffer search behavior that must be reconciled.
  - Pattern: `lua/plugins/nvim-lspconfig.lua:70` - Telescope-backed references map currently in LSP attach flow.
  - Pattern: `lua/plugins/nvim-lspconfig.lua:79` - Telescope-backed definition flow currently in LSP attach flow.

  **Acceptance Criteria**:
  - [ ] `lua/plugins/telescope.lua` is removed from the active configuration.
  - [ ] Search and LSP fuzzy navigation commands resolve through Snacks only.
  - [ ] Protected mappings in the search/LSP namespaces have one owner and pass `require('smoke').assert_provider_policy()`.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Snacks owns the surviving search and LSP UI flows
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').assert_provider_policy()" +qa` after migrating the mappings and plugin specs.
    Expected: The assertion confirms Snacks is the only active owner for picker/search/LSP fuzzy UI.
    Evidence: .sisyphus/evidence/task-4-snacks-provider.txt

  Scenario: Removed Telescope dependency is caught if any mapping still references it
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` after removing Telescope from the plugin graph.
    Expected: Any stale `require('telescope...')` reference would fail startup; final state exits 0.
    Evidence: .sisyphus/evidence/task-4-snacks-provider-error.txt
  ```

  **Commit**: YES | Message: `refactor(nvim): consolidate picker and lsp ui on snacks` | Files: `lua/plugins/snacks.lua`, `lua/plugins/telescope.lua`, `lua/plugins/nvim-lspconfig.lua`, smoke assertions

- [x] 5. Keep mini.statusline and modernize which-key ownership

  **What to do**: Retain `mini.statusline` as the statusline owner, remove `lualine.nvim`, and rewrite the which-key configuration to current, valid plugin usage. Which-key should document leader groups and intentional key families only; it must not carry malformed commands or act as a hidden second source of mappings.
  **Must NOT do**: Do not introduce a second statusline provider or keep placeholder which-key mappings that do not correspond to real commands.

  **Recommended Agent Profile**:
  - Category: `code` - Reason: requires careful cleanup of overlapping UI providers and incorrect config structure.
  - Skills: `[]` - no external skill needed.
  - Omitted: `visual-engineering` - this is runtime/config work, not design work.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: `6` | Blocked By: `1`, `2`

  **References**:
  - Pattern: `lua/plugins/mini.lua:23` - current active `mini.statusline` setup to preserve as the chosen owner.
  - Pattern: `lua/plugins/lualine.lua:1` - overlapping statusline provider to remove.
  - Pattern: `lua/plugins/which-key.lua:3` - malformed event/comment structure showing config drift.
  - Pattern: `lua/plugins/which-key.lua:44` - group-registration pattern to preserve conceptually, but in a corrected shape.
  - Pattern: `lua/plugins/which-key.lua:50` - invalid command mapping block to replace with real which-key options/registrations.

  **Acceptance Criteria**:
  - [ ] Only `mini.statusline` remains as the statusline provider.
  - [ ] `which-key.nvim` loads with valid configuration and registers only real, surviving key groups.
  - [ ] Smoke validation passes without malformed command strings or which-key setup errors.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Statusline and which-key load cleanly
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` after removing lualine and correcting which-key setup.
    Expected: Exit 0 with no plugin-setup errors and with provider assertions still passing.
    Evidence: .sisyphus/evidence/task-5-statusline-whichkey.txt

  Scenario: Malformed which-key config would fail startup if left behind
    Tool: Bash
    Steps: Run the same smoke command after verifying that no stale malformed command strings such as the existing dashboard typo remain.
    Expected: Final configuration exits 0; any leftover malformed mapping would have caused an error or bad registration.
    Evidence: .sisyphus/evidence/task-5-statusline-whichkey-error.txt
  ```

  **Commit**: YES | Message: `refactor(nvim): keep mini statusline and modernize which-key` | Files: `lua/plugins/mini.lua`, `lua/plugins/lualine.lua`, `lua/plugins/which-key.lua`, smoke assertions if needed

- [x] 6. Resolve navigation and key ownership policy

  **What to do**: Keep `vim-tmux-navigator` as the owner of `<C-h/j/k/l>` and remove the duplicate core mappings from `lua/keymaps.lua`. Normalize the global-vs-buffer-local policy so that universal actions stay global, LSP/VCS/filetype actions stay buffer-local or plugin-local, and the protected leader namespaces have one explicit owner. Preserve existing high-frequency workflows with intentional aliases only where they materially reduce migration pain.
  **Must NOT do**: Do not keep duplicate bindings active for the same action, and do not scatter new mappings across unrelated modules.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: user-facing ergonomics plus cross-module ownership decisions make this a high-risk consolidation task.
  - Skills: `[]` - direct code changes are enough.
  - Omitted: `frontend-ui-ux` - editor ergonomics here are config-policy work, not frontend design.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: `8` | Blocked By: `1`, `4`, `5`

  **References**:
  - Pattern: `init.lua:4` - leader/localleader are already defined early and should remain so.
  - Pattern: `lua/keymaps.lua:29` - duplicate global split-navigation keys to remove.
  - Pattern: `lua/plugins/vim-tmux-navigator.lua:11` - chosen owner for cross-pane navigation.
  - Pattern: `lua/plugins/nvim-lspconfig.lua:48` - strong buffer-local LSP mapping pattern to preserve.
  - Pattern: `lua/plugins/gitsigns.lua:10` - strong buffer-local VCS mapping pattern to preserve.
  - Pattern: `lua/plugins/snacks.lua:183` - overlapping leader search namespace that must remain single-owner after consolidation.

  **Acceptance Criteria**:
  - [ ] `<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>` have one intentional owner.
  - [ ] Protected leader namespaces pass `require('smoke').assert_keymap_policy()`.
  - [ ] Global mappings are limited to universal actions; context-heavy actions remain buffer-local or plugin-local.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Protected key ownership is collision-free
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').assert_keymap_policy()" +qa` after key ownership cleanup.
    Expected: The assertion reports one owner for each protected key namespace and exits 0.
    Evidence: .sisyphus/evidence/task-6-key-ownership.txt

  Scenario: Duplicate navigation bindings are detected if left behind
    Tool: Bash
    Steps: Run the keymap assertion after verifying the `<C-h/j/k/l>` policy; any remaining duplicate mapping definitions should cause the assertion to fail.
    Expected: Final state exits 0 only when duplicates are removed or explicitly whitelisted as intentional aliases.
    Evidence: .sisyphus/evidence/task-6-key-ownership-error.txt
  ```

  **Commit**: YES | Message: `refactor(nvim): resolve navigation and key ownership` | Files: `lua/keymaps.lua`, `lua/plugins/vim-tmux-navigator.lua`, any mapping owner files touched by the consolidation

- [x] 7. Align runtime policy, event triggers, and optional dependency behavior

  **What to do**: Standardize the runtime contract around `Neovim 0.11+`, using the same baseline and messaging in `startup-validation` and `health`. Remove dead or distribution-specific startup hooks, narrow noisy lint triggers to a more intentional policy, and make format mappings explicit about supported modes. Keep optional external binaries as warnings/skips unless they are hard requirements for the config to boot.
  **Must NOT do**: Do not silently hard-fail the editor on missing optional tooling, and do not leave contradictory version checks in different modules.

  **Recommended Agent Profile**:
  - Category: `code` - Reason: concrete runtime/event cleanup with measurable verification.
  - Skills: `[]` - no extra skills required.
  - Omitted: `unspecified-high` - the task is bounded and code-focused.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: `8` | Blocked By: `1`

  **References**:
  - Pattern: `lua/startup-validation.lua:3` - current startup version/executable policy to align with health and smoke behavior.
  - Pattern: `lua/health.lua:8` - current custom health version check still targeting `0.10-dev`.
  - Pattern: `lua/lazy-plugins.lua:106` - `LazyVimStarted` autocmd that appears invalid for this repo and should be removed or replaced.
  - Pattern: `lua/plugins/lint.lua:48` - current lint event fan-out to tighten.
  - Pattern: `lua/plugins/conform.lua:5` - format mapping currently uses `mode = ""`, which should become explicit.
  - Pattern: `lua/options.lua:18` - comment drift around clipboard scheduling to reconcile with actual behavior.

  **Acceptance Criteria**:
  - [ ] Startup validation and custom health checks report the same `0.11+` baseline and same policy semantics.
  - [ ] Lint and format behavior follow an explicit final event/mode policy.
  - [ ] Smoke validation passes with clear warning/skip output when optional executables are absent.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Runtime contract is internally consistent
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+checkhealth" +qa` and `nvim --headless -u init.lua "+lua require('smoke').run()" +qa` after aligning version and runtime policy.
    Expected: Both commands reflect `Neovim 0.11+`, no contradictory messages appear, and both exit 0 on a supported environment.
    Evidence: .sisyphus/evidence/task-7-runtime-policy.txt

  Scenario: Optional tooling absence stays non-fatal
    Tool: Bash
    Steps: Run the smoke command in an environment missing one optional lint/format executable and inspect the resulting output.
    Expected: Clear warning/skip behavior; no crash and no contradictory health error.
    Evidence: .sisyphus/evidence/task-7-runtime-policy-error.txt
  ```

  **Commit**: YES | Message: `fix(nvim): align runtime policy and event triggers` | Files: `lua/startup-validation.lua`, `lua/health.lua`, `lua/lazy-plugins.lua`, `lua/plugins/lint.lua`, `lua/plugins/conform.lua`, `lua/options.lua`

- [x] 8. Split hotspot modules into smaller ownership-focused files

  **What to do**: After provider and keymap ownership are stable, break the largest mixed-responsibility modules into smaller files so plugin spec, key definitions, and feature-specific behavior are easier to scan and safer to evolve. At minimum, reduce the scope of `lua/plugins/snacks.lua` and `lua/plugins/nvim-lspconfig.lua` by extracting cohesive helpers or submodules organized by capability.
  **Must NOT do**: Do not abstract for abstraction's sake, and do not create a new framework layer that hides simple plugin config behind needless indirection.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: architecture-sensitive refactor with high regression risk if done before consolidation stabilizes.
  - Skills: `[]` - normal refactoring tools are enough.
  - Omitted: `quick` - this task is too structurally significant for a trivial pass.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: none | Blocked By: `2`, `4`, `6`, `7`

  **References**:
  - Pattern: `lua/plugins/snacks.lua:1` - large mixed plugin spec and keymap file to split by capability.
  - Pattern: `lua/plugins/snacks.lua:44` - keymap section that should be isolated from plugin-option declaration.
  - Pattern: `lua/plugins/nvim-lspconfig.lua:18` - large all-in-one LSP config function to divide into smaller concerns.
  - Pattern: `lua/plugins/nvim-lspconfig.lua:48` - LSP attach/mapping logic that should live in a dedicated helper.
  - Pattern: `lua/plugins/nvim-lspconfig.lua:162` - diagnostic config block that can be isolated from server registration.
  - Pattern: `lua/plugins/nvim-lspconfig.lua:206` - server registry/tool-install section that can stand alone.

  **Acceptance Criteria**:
  - [ ] The largest plugin hotspot files are materially smaller and organized by capability.
  - [ ] Plugin spec declaration, keymaps, and feature-specific behavior are no longer mixed in one monolithic block where a smaller boundary is practical.
  - [ ] Full smoke validation and provider/keymap assertions still pass after the refactor.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```text
  Scenario: Modularized hotspots keep behavior intact
    Tool: Bash
    Steps: Run `nvim --headless -u init.lua "+lua require('smoke').run()" +qa`, `nvim --headless -u init.lua "+lua require('smoke').assert_provider_policy()" +qa`, and `nvim --headless -u init.lua "+lua require('smoke').assert_keymap_policy()" +qa` after the split.
    Expected: All commands exit 0 and the refactor introduces no module-loading regressions.
    Evidence: .sisyphus/evidence/task-8-module-split.txt

  Scenario: Broken extracted module is caught immediately
    Tool: Bash
    Steps: Run the same verification commands after the module split; any bad require path or lost helper should fail startup or assertions.
    Expected: Final state exits 0 only when all extracted modules are wired correctly.
    Evidence: .sisyphus/evidence/task-8-module-split-error.txt
  ```

  **Commit**: YES | Message: `refactor(nvim): split hotspot config modules` | Files: `lua/plugins/snacks.lua`, `lua/plugins/nvim-lspconfig.lua`, new helper modules under `lua/plugins/` or adjacent capability folders

## Final Verification Wave (MANDATORY - after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit - oracle
- [x] F2. Code Quality Review - unspecified-high
- [x] F3. Real Manual QA - unspecified-high (+ playwright if UI)
- [x] F4. Scope Fidelity Check - deep

## Commit Strategy
- Commit after each completed task or tightly-coupled pair when the smoke check for that slice is green.
- Use this order:
  - `test(nvim): add smoke validation entrypoint`
  - `refactor(nvim): normalize plugin registration`
  - `chore(nvim): remove dormant plugin configs`
  - `refactor(nvim): consolidate picker and lsp ui on snacks`
  - `refactor(nvim): keep mini statusline and modernize which-key`
  - `refactor(nvim): resolve navigation and key ownership`
  - `fix(nvim): align runtime policy and event triggers`
  - `refactor(nvim): split hotspot config modules`

## Success Criteria
- The config boots cleanly on `Neovim 0.11+`
- Provider overlap is removed for the chosen domains
- Protected key namespaces have one intentional owner each
- Version, health, and optional dependency policy are internally consistent
- The resulting layout is easier to scan: plugin specs live under `lua/plugins/`, dead modules are gone, and the largest remaining config files have clearer boundaries
