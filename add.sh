#!/usr/bin/env bash
#
# add.sh - Add a config file or directory to dotfiles
#
# Usage:
#   ./add.sh <package> <source-path>
#
# Examples:
#   ./add.sh zsh ~/.zshrc
#   ./add.sh nvim ~/.config/nvim
#   ./add.sh git ~/.gitconfig
#   ./add.sh alacritty ~/.config/alacritty
#

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat <<EOF
Usage: ./add.sh <package> <source-path>

Add a config file or directory to your dotfiles repo.

Arguments:
  package       Name of the stow package (e.g., zsh, nvim, git)
  source-path   Path to the config file/directory to add

Examples:
  ./add.sh zsh ~/.zshrc              # Add .zshrc to 'zsh' package
  ./add.sh nvim ~/.config/nvim       # Add nvim config to 'nvim' package
  ./add.sh git ~/.gitconfig          # Add .gitconfig to 'git' package

What this script does:
  1. Creates the package directory structure
  2. Copies the source into the package (preserving $HOME-relative path)
  3. Removes the original
  4. Stows the package (creates symlink)
  5. Shows files that might need to be added to .gitignore

EOF
    exit 1
}

# Expand path to absolute
expand_path() {
    local path="$1"
    # Handle ~ expansion
    path="${path/#\~/$HOME}"
    # Get absolute path
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -f "$path" ]]; then
        local dir
        dir=$(cd "$(dirname "$path")" && pwd)
        echo "$dir/$(basename "$path")"
    else
        echo "$path"
    fi
}

# Get path relative to HOME
relative_to_home() {
    local path="$1"
    echo "${path#$HOME/}"
}

# Main
main() {
    if [[ $# -lt 2 ]]; then
        usage
    fi

    local package="$1"
    local source_path
    source_path=$(expand_path "$2")
    local relative_path
    relative_path=$(relative_to_home "$source_path")

    # Validation
    if [[ ! -e "$source_path" ]]; then
        error "Source path does not exist: $source_path"
        exit 1
    fi

    if [[ "$source_path" != "$HOME/"* ]]; then
        error "Source path must be under \$HOME"
        error "Got: $source_path"
        exit 1
    fi

    if [[ -L "$source_path" ]]; then
        error "Source is already a symlink: $source_path"
        error "It may already be managed by stow"
        exit 1
    fi

    local dest_dir="$DOTFILES_DIR/$package"
    local dest_path="$dest_dir/$relative_path"

    echo ""
    echo "================================"
    echo "  Add Config to Dotfiles"
    echo "================================"
    echo ""
    info "Package:     $package"
    info "Source:      $source_path"
    info "Destination: $dest_path"
    echo ""

    # Confirm
    read -rp "Proceed? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info "Aborted"
        exit 0
    fi
    echo ""

    # Step 1: Create directory structure
    info "Creating package structure..."
    mkdir -p "$(dirname "$dest_path")"
    success "Directory created"

    # Step 2: Copy source to package
    info "Copying to dotfiles repo..."
    if [[ -d "$source_path" ]]; then
        # For directories, copy contents (excluding .git if present)
        rsync -av --exclude='.git' "$source_path/" "$dest_path/"
    else
        cp -a "$source_path" "$dest_path"
    fi
    success "Copied"

    # Step 3: Verify copy
    if [[ -d "$source_path" ]]; then
        local src_count dest_count
        src_count=$(find "$source_path" -type f ! -path '*/.git/*' | wc -l | tr -d ' ')
        dest_count=$(find "$dest_path" -type f | wc -l | tr -d ' ')
        if [[ "$src_count" != "$dest_count" ]]; then
            error "File count mismatch: source=$src_count, dest=$dest_count"
            error "Please verify manually before removing original"
            exit 1
        fi
        success "Verified: $src_count files copied"
    fi

    # Step 4: Remove original
    info "Removing original..."
    rm -rf "$source_path"
    success "Original removed"

    # Step 5: Stow the package
    info "Stowing package..."
    cd "$DOTFILES_DIR"
    if stow -t "$HOME" "$package"; then
        success "Package stowed"
    else
        error "Stow failed. You may need to resolve conflicts manually."
        exit 1
    fi

    # Step 6: Verify symlink
    info "Verifying symlink..."
    if [[ -L "$source_path" ]] || [[ -L "$(dirname "$source_path")" ]]; then
        success "Symlink verified"
    else
        warn "Could not verify symlink. Please check manually."
    fi

    # Step 7: Check for files that might need gitignore
    echo ""
    info "Checking for generated files to ignore..."
    cd "$DOTFILES_DIR"
    local untracked
    untracked=$(git status --porcelain "$package" 2>/dev/null | grep -E '^\?\?' | head -20 || true)

    if [[ -n "$untracked" ]]; then
        warn "New untracked files detected. Review and add to .gitignore if needed:"
        echo "$untracked" | while read -r line; do
            echo "  ${line#\?\? }"
        done
        echo ""
        info "Edit .gitignore: $DOTFILES_DIR/.gitignore"
    else
        success "No obvious generated files detected"
    fi

    echo ""
    success "Done! Config added to '$package' package"
    info "Next steps:"
    echo "  1. Review 'git status' for files to ignore"
    echo "  2. Update .gitignore if needed"
    echo "  3. Commit: git add -A && git commit -m 'feat: add $package config'"
    echo ""
}

main "$@"
