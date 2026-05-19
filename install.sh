#!/bin/bash

# Ensure script is NOT run as root/sudo directly
if [ "$EUID" -eq 0 ]; then
    echo "Please do NOT run this script with sudo or as root."
    echo "Run it as a normal user: ./script.sh"
    exit 1
fi

if ! grep -q "Arch" /etc/os-release; then
    echo "This script only supports Arch Linux"
    exit 1
fi

DOTFILES_DIR="$HOME/hyprland-dotfiles"

set -e

# Ask sudo password once
sudo -v

# Keep sudo session alive
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

echo "========== UPDATE SYSTEM =========="
sudo pacman -Syu --noconfirm

echo "========== INSTALL BASE PACKAGES =========="
sudo pacman -S --needed --noconfirm git base-devel stow

echo "========== CHECK YAY =========="
if ! command -v yay &> /dev/null; then
    echo "yay not found. Installing yay..."
    
    # Save current dir
    CURRENT_DIR=$(pwd)
    
    cd /tmp
    # Clean up old clone if exists
    rm -rf yay 
    git clone https://aur.archlinux.org/yay.git
    cd yay
    
    # makepkg will use the sudo session we kept alive above
    makepkg -si --noconfirm
    
    cd "$CURRENT_DIR"
    echo "yay installed."
else
    echo "yay already installed."
fi

echo "========== INSTALL PACMAN PACKAGES =========="
if [ -f "$DOTFILES_DIR/packages/pacman.txt" ]; then
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/packages/pacman.txt"
fi

echo "========== INSTALL AUR PACKAGES =========="
if [ -f "$DOTFILES_DIR/packages/aur.txt" ]; then
    # yay should run as normal user, NOT sudo
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/packages/aur.txt"
fi

echo "========== STOW CONFIGS =========="
cd "$DOTFILES_DIR"

for dir in */; do
    dir_name="${dir%/}"
    
    # Skip packages directory
    if [[ "$dir_name" != "packages" ]]; then
        echo "Stowing $dir_name..."
        
        # Use --adopt to safely absorb any existing conflicting configs/symlinks
        stow --adopt "$dir_name"
    fi
done

# CRITICAL STEP: When using --adopt, if there were local changes in ~/, 
# stow might have modified files inside your git repo. 
# We reset them to keep your dotfiles repository clean as intended.
echo "Cleaning up adopted tracking changes..."
git reset --hard HEAD

echo "========== DONE =========="
