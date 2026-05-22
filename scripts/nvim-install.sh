#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$HOME/.config"
rm -rf "$HOME/.config/nvim"
ln -sfn "$DOTFILES_DIR" "$HOME/.config/nvim"

# if command -v nvim >/dev/null 2>&1; then
#   nvim --headless '+Lazy! sync' +qa || true
# fi
