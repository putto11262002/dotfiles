#!/usr/bin/env bash
#
# add.sh - Add a config to dotfiles
#
# Usage: ./add.sh <package> <source>
#
# Examples:
#   ./add.sh zsh ~/.zshrc
#   ./add.sh git ~/.gitconfig
#   ./add.sh alacritty ~/.config/alacritty
#

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: ./add.sh <package> <source>"
    echo ""
    echo "Examples:"
    echo "  ./add.sh zsh ~/.zshrc"
    echo "  ./add.sh git ~/.gitconfig"
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
package="$1"
source="${2/#\~/$HOME}"  # expand ~

# Validate
if [[ ! -e "$source" ]]; then
    echo "Error: $source does not exist"
    exit 1
fi

if [[ -L "$source" ]]; then
    echo "Error: $source is already a symlink"
    exit 1
fi

if [[ "$source" != "$HOME/"* ]]; then
    echo "Error: source must be under \$HOME"
    exit 1
fi

# Paths
relative="${source#$HOME/}"
dest="$DOTFILES_DIR/$package/$relative"

echo "Package: $package"
echo "Source:  $source"
echo "Dest:    $dest"
echo ""

read -rp "Proceed? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# Copy
mkdir -p "$(dirname "$dest")"
cp -R "$source" "$dest"

# Remove original
rm -rf "$source"

# Stow
cd "$DOTFILES_DIR"
stow -t "$HOME" "$package"

echo ""
echo "Done. Check 'git status' for files to ignore."
