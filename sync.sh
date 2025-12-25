#!/usr/bin/env bash
#
# sync.sh - Pull latest changes and restow packages
#
# Usage:
#   ./sync.sh           # Pull and restow all packages
#   ./sync.sh --push    # Also push local commits after sync
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

# Get list of stow packages
get_packages() {
    find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
        ! -name ".*" \
        -exec basename {} \; | sort
}

# Check for uncommitted changes
check_dirty() {
    cd "$DOTFILES_DIR"
    if ! git diff --quiet || ! git diff --cached --quiet; then
        return 0  # dirty
    fi
    return 1  # clean
}

# Pull latest changes
pull_changes() {
    cd "$DOTFILES_DIR"

    if check_dirty; then
        warn "You have uncommitted changes"
        info "Stashing changes before pull..."
        git stash push -m "sync.sh auto-stash $(date +%Y-%m-%d_%H:%M:%S)"
        local stashed=true
    fi

    info "Pulling latest changes..."
    if git pull --rebase; then
        success "Pull complete"
    else
        error "Pull failed. Resolve conflicts and try again."
        if [[ "${stashed:-false}" == "true" ]]; then
            warn "Your changes are stashed. Run 'git stash pop' to restore."
        fi
        exit 1
    fi

    if [[ "${stashed:-false}" == "true" ]]; then
        info "Restoring stashed changes..."
        if git stash pop; then
            success "Stash restored"
        else
            warn "Stash restore had conflicts. Resolve manually."
        fi
    fi
}

# Push local commits
push_changes() {
    cd "$DOTFILES_DIR"

    local ahead
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")

    if [[ "$ahead" -gt 0 ]]; then
        info "Pushing $ahead local commit(s)..."
        if git push; then
            success "Push complete"
        else
            error "Push failed"
            exit 1
        fi
    else
        info "Nothing to push"
    fi
}

# Restow all packages (to pick up any new files/packages)
restow_packages() {
    local packages
    packages=$(get_packages)

    if [[ -z "$packages" ]]; then
        warn "No packages found"
        return
    fi

    info "Restowing packages..."
    cd "$DOTFILES_DIR"

    for pkg in $packages; do
        # Use -R to restow (unstow then stow)
        if stow -R -t "$HOME" "$pkg" 2>&1; then
            success "  $pkg"
        else
            error "  Failed to restow $pkg"
        fi
    done
}

# Main
main() {
    local push_after=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --push|-p)
                push_after=true
                shift
                ;;
            --help|-h)
                echo "Usage: ./sync.sh [--push]"
                echo ""
                echo "Options:"
                echo "  --push, -p    Push local commits after syncing"
                echo "  --help, -h    Show this help"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    echo ""
    echo "================================"
    echo "  Dotfiles Sync"
    echo "================================"
    echo ""

    pull_changes
    restow_packages

    if [[ "$push_after" == "true" ]]; then
        push_changes
    fi

    echo ""
    success "Sync complete!"
    echo ""
}

main "$@"
