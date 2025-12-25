#!/usr/bin/env bash
#
# sync.sh - Pull latest and restow all packages
#
# Usage: ./sync.sh
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: uncommitted changes exist"
    echo "  Commit or stash your changes first"
    exit 1
fi

# Pull
echo "Pulling..."
git pull

# Restow all packages
packages=$(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".*" -exec basename {} \; | sort)

if [[ -z "$packages" ]]; then
    echo "No packages to restow"
    exit 0
fi

echo "Restowing packages..."
for pkg in $packages; do
    echo "  $pkg"
    stow -R -t "$HOME" "$pkg"
done

echo "Done"
