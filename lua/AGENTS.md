# Neovim Lua (nvim/lua/)

## Overview
Lua modules for options, keymaps, startup validation, and plugin configuration.

## Structure (partial)
```
 nvim/lua/
 ├── lazy-bootstrap.lua
 ├── lazy-plugins.lua
 ├── options.lua
 ├── keymaps.lua
 ├── startup-validation.lua
 ├── config/    # Implementations delegated from plugin specs
 └── plugins/
```

## Start Here
- Plugin specs: `nvim/lua/plugins/` is auto-imported by `lazy-plugins.lua` using `{ import = "plugins" }`.
- LSP implementation: `nvim/lua/config/lsp/{attach,diagnostics,servers}.lua`.
- Snacks implementation: `nvim/lua/config/snacks/{init,options,keys}.lua`.

## Notes
Add plugin specs under `nvim/lua/plugins/`; do not manually register individual files in `lazy-plugins.lua`.
