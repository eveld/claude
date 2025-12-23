#!/bin/bash
set -e

CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude.backup"
OLD_DIR="$HOME/.claude.old"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

show_usage() {
    echo "Usage: $0 [new|old|status]"
    echo ""
    echo "Commands:"
    echo "  new     - Switch to new skills-based setup"
    echo "  old     - Restore old monolithic setup"
    echo "  status  - Show current setup status"
    exit 1
}

check_dirs() {
    echo "Current state:"
    if [ -L "$CLAUDE_DIR" ]; then
        echo "  ~/.claude -> $(readlink "$CLAUDE_DIR") (symlink)"
    elif [ -d "$CLAUDE_DIR" ]; then
        echo "  ~/.claude exists (directory)"
    else
        echo "  ~/.claude does not exist"
    fi

    [ -d "$BACKUP_DIR" ] && echo "  ~/.claude.backup exists"
    [ -d "$OLD_DIR" ] && echo "  ~/.claude.old exists"
}

switch_to_new() {
    echo "Switching to new skills-based setup..."

    # Backup current setup if it exists and no backup exists yet
    if [ -d "$CLAUDE_DIR" ] && [ ! -d "$BACKUP_DIR" ]; then
        echo "Creating backup at ~/.claude.backup/..."
        cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
    fi

    # Move current setup to .old
    if [ -d "$CLAUDE_DIR" ]; then
        echo "Moving current setup to ~/.claude.old/..."
        rm -rf "$OLD_DIR"
        mv "$CLAUDE_DIR" "$OLD_DIR"
    fi

    # Copy new setup from repo
    echo "Installing new setup from $REPO_DIR..."
    mkdir -p "$CLAUDE_DIR"

    # Copy only the necessary directories
    [ -d "$REPO_DIR/agents" ] && cp -r "$REPO_DIR/agents" "$CLAUDE_DIR/"
    [ -d "$REPO_DIR/commands" ] && cp -r "$REPO_DIR/commands" "$CLAUDE_DIR/"
    [ -d "$REPO_DIR/skills" ] && cp -r "$REPO_DIR/skills" "$CLAUDE_DIR/"
    [ -d "$REPO_DIR/scripts" ] && cp -r "$REPO_DIR/scripts" "$CLAUDE_DIR/"
    [ -d "$REPO_DIR/templates" ] && cp -r "$REPO_DIR/templates" "$CLAUDE_DIR/"

    echo "✓ New setup installed successfully"
    echo ""
    echo "To test: Run '/research' or ask Claude to find files"
    echo "To rollback: Run '$0 old'"
}

switch_to_old() {
    echo "Switching back to old monolithic setup..."

    if [ ! -d "$OLD_DIR" ]; then
        echo "Error: No old setup found at ~/.claude.old/"
        echo "Cannot restore. Use backup if needed: ~/.claude.backup/"
        exit 1
    fi

    # Remove new setup
    if [ -d "$CLAUDE_DIR" ]; then
        echo "Removing new setup..."
        rm -rf "$CLAUDE_DIR"
    fi

    # Restore old setup
    echo "Restoring old setup from ~/.claude.old/..."
    mv "$OLD_DIR" "$CLAUDE_DIR"

    echo "✓ Old setup restored successfully"
    echo ""
    echo "To switch back to new: Run '$0 new'"
}

case "${1:-}" in
    new)
        switch_to_new
        ;;
    old)
        switch_to_old
        ;;
    status)
        check_dirs
        ;;
    *)
        show_usage
        ;;
esac
