#!/bin/bash

###############################################################
#                                                             #
#  add-stow.sh                                                #
#                                                             #
#  Usage:                                                     #
#    bash scripts/add-stow.sh hypr ~/.config/hypr             #
#                                                             #
#  This script will:                                          #
#    1. Create stow package structure                         #
#    2. Move existing config into dotfiles repo               #
#    3. Create symlink using GNU Stow                         #
#                                                             #
#  Example result:                                            #
#                                                             #
#    dotfiles/                                                #
#    └── hypr/                                                #
#        └── .config/                                         #
#            └── hypr/                                        #
#                                                             #
#  Symlink:                                                   #
#                                                             #
#    ~/.config/hypr                                           #
#      → ~/dotfiles/hypr/.config/hypr                         #
#                                                             #
###############################################################

set -e

DOTFILES_DIR="$HOME/hyprland-dotfiles"

usage() {
    echo "Usage:"
    echo "  bash scripts/add-stow.sh <package-name> <target-path>"
    echo ""
    echo "Example:"
    echo "  bash scripts/add-stow.sh hypr ~/.config/hypr"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

PACKAGE_NAME="$1"
TARGET_PATH=$(eval echo "$2")

if [ ! -e "$TARGET_PATH" ]; then
    echo "Target does not exist:"
    echo "$TARGET_PATH"
    exit 1
fi

RELATIVE_PATH=""

if [[ "$TARGET_PATH" == "$HOME/.config/"* ]]; then
    RELATIVE_PATH=".config/$PACKAGE_NAME"

elif [[ "$TARGET_PATH" == "$HOME/.local/bin/"* ]]; then
    RELATIVE_PATH=".local/bin"

elif [[ "$TARGET_PATH" == "$HOME/"* ]]; then
    BASENAME=$(basename "$TARGET_PATH")
    RELATIVE_PATH="$BASENAME"

else
    echo "Unsupported path:"
    echo "$TARGET_PATH"
    exit 1
fi

PACKAGE_DIR="$DOTFILES_DIR/$PACKAGE_NAME"

echo "Creating package structure..."

mkdir -p "$PACKAGE_DIR"

DESTINATION="$PACKAGE_DIR/$RELATIVE_PATH"

mkdir -p "$(dirname "$DESTINATION")"

echo "Moving files..."

mv "$TARGET_PATH" "$DESTINATION"

echo "Running stow..."

cd "$DOTFILES_DIR"

stow "$PACKAGE_NAME"

echo ""
echo "Done!"
echo ""
echo "Symlink created:"
echo "$TARGET_PATH -> $DESTINATION"
