# Neovim (nvim/)

## Overview
Neovim configuration entrypoint and plugin bootstrap.

## Where To Look
- Entry: `nvim/init.lua`
- Plugin bootstrap: `nvim/lua/lazy-bootstrap.lua`
- Plugin list: `nvim/lua/lazy-plugins.lua`
- Formatter map: `nvim/lua/plugins/conform.lua`
- Linter map: `nvim/lua/plugins/lint.lua`

## Guardrails
- `nvim/lazy-lock.json` is managed by `lazy.nvim` (do not hand-edit; do not manage via Nix).

## Notes
Plugin-specific configuration lives under `nvim/lua/plugins/`.
