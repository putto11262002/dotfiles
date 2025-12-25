#!/usr/bin/env bash
#
# bootstrap.sh - Stow all packages
#
# Usage: ./bootstrap.sh
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check prerequisites
if ! command -v stow &>/dev/null; then
    echo "Error: stow is not installed"
    echo "  macOS:  brew install stow"
    echo "  Ubuntu: sudo apt install stow"
    exit 1
fi

# Get all packages (top-level directories, excluding hidden)
packages=$(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".*" -exec basename {} \; | sort)

if [[ -z "$packages" ]]; then
    echo "No packages found"
    exit 0
fi

echo "Stowing packages..."
cd "$DOTFILES_DIR"

for pkg in $packages; do
    echo "  $pkg"
    stow -t "$HOME" "$pkg"
done

echo "Done"
