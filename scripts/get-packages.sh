#!/bin/bash

# Exit on error
set -e

# Get the directory of this script and the root of the repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Define package file paths in the repo
PACMAN_FILE="$REPO_DIR/packages/pacman.txt"
AUR_FILE="$REPO_DIR/packages/aur.txt"

# Help message
show_help() {
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Options:"
    echo "  -a, --all      List all explicitly installed packages (native & foreign)"
    echo "  -p, --pacman   List explicitly installed native (pacman repo) packages"
    echo "  -u, --aur      List explicitly installed foreign (AUR) packages"
    echo "  -g, --git      List explicitly installed VCS/git packages (ending in -git)"
    echo "  -s, --save     Save explicitly installed packages to packages/pacman.txt and packages/aur.txt"
    echo "  -h, --help     Show this help message"
}

# Functions to query packages
get_pacman() {
    pacman -Qqen | sort -u
}

get_aur() {
    pacman -Qqem | sort -u
}

get_git() {
    pacman -Qqe | grep -E '\-(git|svn|hg|darcs|bzr)$' | sort -u || true
}

# Ensure pacman is available
if ! command -v pacman &>/dev/null; then
    echo "Error: 'pacman' package manager not found. This script must be run on Arch Linux." >&2
    exit 1
fi

# Flag variables
SHOW_ALL=false
SHOW_PACMAN=false
SHOW_AUR=false
SHOW_GIT=false
SAVE_FILES=false
HAS_OPTS=false

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -a|--all)
            SHOW_ALL=true
            HAS_OPTS=true
            shift
            ;;
        -p|--pacman)
            SHOW_PACMAN=true
            HAS_OPTS=true
            shift
            ;;
        -u|--aur)
            SHOW_AUR=true
            HAS_OPTS=true
            shift
            ;;
        -g|--git)
            SHOW_GIT=true
            HAS_OPTS=true
            shift
            ;;
        -s|--save)
            SAVE_FILES=true
            HAS_OPTS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            show_help >&2
            exit 1
            ;;
    esac
done

# If no options are specified, default to --all
if [ "$HAS_OPTS" = false ]; then
    SHOW_ALL=true
fi

# Perform save/update if requested
if [ "$SAVE_FILES" = true ]; then
    echo "Saving/updating package lists in dotfiles repository..."
    
    # Ensure package directory exists
    mkdir -p "$(dirname "$PACMAN_FILE")"
    
    # Write native pacman packages
    get_pacman > "$PACMAN_FILE"
    echo "Saved $(wc -l < "$PACMAN_FILE") pacman packages to $PACMAN_FILE"
    
    # Write AUR packages
    get_aur > "$AUR_FILE"
    echo "Saved $(wc -l < "$AUR_FILE") AUR packages to $AUR_FILE"
    
    echo "Successfully updated package list files."
    exit 0
fi

# Output package lists
if [ "$SHOW_ALL" = true ]; then
    # Show everything combined, or separated?
    # To be extremely clean and pipeable, let's output everything sorted without headers if stdout is piped, 
    # but with nice headers if it's an interactive terminal (stdout is TTY).
    if [ -t 1 ]; then
        echo "=== Explicitly Installed Pacman Packages ==="
        get_pacman
        echo ""
        echo "=== Explicitly Installed AUR Packages ==="
        get_aur
    else
        # Combined sorted list for piping/scripting
        (get_pacman; get_aur) | sort -u
    fi
    exit 0
fi

# Individual lists
if [ "$SHOW_PACMAN" = true ]; then
    if [ -t 1 ] && [ "$SHOW_AUR" = true ]; then
        echo "=== Explicitly Installed Pacman Packages ==="
    fi
    get_pacman
fi

if [ "$SHOW_AUR" = true ]; then
    if [ -t 1 ] && [ "$SHOW_PACMAN" = true ]; then
        echo ""
        echo "=== Explicitly Installed AUR Packages ==="
    fi
    get_aur
fi

if [ "$SHOW_GIT" = true ]; then
    if [ -t 1 ] && { [ "$SHOW_PACMAN" = true ] || [ "$SHOW_AUR" = true ]; }; then
        echo ""
        echo "=== VCS/Git Packages ==="
    fi
    get_git
fi
