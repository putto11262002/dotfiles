#!/usr/bin/env bash
#
# status.sh - Show status of packages
#
# Usage: ./status.sh
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get all packages
packages=$(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".*" -exec basename {} \; | sort)

if [[ -z "$packages" ]]; then
    echo "No packages found"
    exit 0
fi

echo "Packages:"
for pkg in $packages; do
    pkg_dir="$DOTFILES_DIR/$pkg"

    # Find first file in package to check if stowed
    first_file=$(find "$pkg_dir" -type f | head -1)

    if [[ -z "$first_file" ]]; then
        echo "  $pkg (empty)"
        continue
    fi

    relative="${first_file#$pkg_dir/}"
    target="$HOME/$relative"

    # Check if target exists (via symlink or parent symlink)
    if [[ -e "$target" ]]; then
        echo "  $pkg (stowed)"
    else
        echo "  $pkg (not stowed)"
    fi
done
