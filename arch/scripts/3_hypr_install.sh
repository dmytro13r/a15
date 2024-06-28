#!/bin/bash

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &> /dev/null
}

# Update the system package database
echo "Updating the system package database..."
sudo pacman -Syu --noconfirm

# Install prerequisites
echo "Installing prerequisites..."
sudo pacman -S --needed base-devel git cmake meson ninja pkgconf libxcb libx11 xcb-util-wm xcb-util-image libxkbcommon xcb-util-keysyms xcb-util-renderutil pango cairo glib2 ttf-liberation --noconfirm

# Install yay if it's not installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Installing yay..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git /opt/yay
    sudo chown -R $(whoami):$(whoami) /opt/yay
    cd /opt/yay
    makepkg -si --noconfirm
    cd ..
    rm -rf /opt/yay
fi

# Install Hyprland and its dependencies using yay
echo "Installing Hyprland and its dependencies..."
yay -S hyprland --noconfirm

# Install other recommended packages
echo "Installing other recommended packages..."
yay -S waybar-hyprland-git swaybg swaylock-effects wofi dunst xorg-xwayland wl-clipboard --noconfirm

# Setup Hyprland configuration (if not already set)
CONFIG_DIR="$HOME/.config/hypr"
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Setting up Hyprland configuration..."
    mkdir -p "$CONFIG_DIR"
    cp /usr/share/hyprland/hyprland.conf.example "$CONFIG_DIR/hyprland.conf"
fi

echo "Hyprland installation complete. You can start Hyprland with the 'Hyprland' command."
