# Neovim Lua (nvim/lua/)

## Overview
Lua modules for options, keymaps, startup validation, and plugin configuration.

## Structure (partial)
```
 nvim/lua/
 ├── plugins/init.lua
 ├── options.lua
 ├── keymaps.lua
 ├── startup-validation.lua
 └── plugins/
```

## Start Here
- Large configs: `nvim/lua/plugins/nvim-lspconfig.lua`, `nvim/lua/plugins/snacks.lua`

## Notes
Add new plugin configuration files under `nvim/lua/plugins/`, then load them from `nvim/lua/plugins/init.lua`.
