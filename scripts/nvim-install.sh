#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$(realpath "$SCRIPT_DIR/..")"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_TARGET="$CONFIG_HOME/nvim"

mkdir -p "$CONFIG_HOME"

if [[ -L "$CONFIG_TARGET" ]]; then
  if [[ "$(realpath -m "$CONFIG_TARGET")" == "$CONFIG_SOURCE" ]]; then
    printf 'Neovim configuration is already linked at %s\n' "$CONFIG_TARGET"
    exit 0
  fi

  printf 'Refusing to replace existing Neovim configuration symlink: %s\n' "$CONFIG_TARGET" >&2
  exit 1
fi

if [[ -e "$CONFIG_TARGET" ]]; then
  printf 'Refusing to replace existing Neovim configuration: %s\n' "$CONFIG_TARGET" >&2
  exit 1
fi

ln -s "$CONFIG_SOURCE" "$CONFIG_TARGET"
