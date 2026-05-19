#!/bin/bash

set -e

DOTFILES_DIR="$HOME/hyprland-dotfiles"

if ! grep -q "Arch" /etc/os-release; then
    echo "This script only supports Arch Linux"
    exit 1
fi

echo "========== UPDATE SYSTEM =========="
sudo pacman -Syu --noconfirm

echo "========== INSTALL BASE PACKAGES =========="
sudo pacman -S --needed --noconfirm \
    git \
    base-devel \
    stow

echo "========== CHECK YAY =========="

if ! command -v yay &> /dev/null
then
    echo "yay not found. Installing yay..."

    cd /tmp

    git clone https://aur.archlinux.org/yay.git
    cd yay

    makepkg -si --noconfirm

    cd ~

    echo "yay installed."
else
    echo "yay already installed."
fi

echo "========== INSTALL PACMAN PACKAGES =========="

if [ -f "$DOTFILES_DIR/packages/pacman.txt" ]; then
    sudo pacman -S --needed --noconfirm - < \
        "$DOTFILES_DIR/packages/pacman.txt"
fi

echo "========== INSTALL AUR PACKAGES =========="

if [ -f "$DOTFILES_DIR/packages/aur.txt" ]; then
    yay -S --needed --noconfirm - < \
        "$DOTFILES_DIR/packages/aur.txt"
fi

echo "========== STOW CONFIGS =========="

cd "$DOTFILES_DIR"

for dir in */
do
    if [[ "$dir" != "packages/" ]]
    then
        stow -R "${dir%/}"
    fi
done

echo "========== DONE =========="
