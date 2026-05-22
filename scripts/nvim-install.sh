#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config"

ln -sfn "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Optional, but useful if nvim exists in the container.
if command -v nvim >/dev/null 2>&1; then
  nvim --headless '+Lazy! sync' +qa || true
fi
