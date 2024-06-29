#!/bin/bash

# Function to add a line to a file if it doesn't already exist
add_line_if_not_exists() {
    local file="$1"
    local line="$2"
    grep -qxF "$line" "$file" || echo "$line" | sudo tee -a "$file" > /dev/null
}

# Function to add a module to mkinitcpio.conf if it doesn't already exist
add_module_if_not_exists() {
    local module="$1"
    if ! grep -q "$module" /etc/mkinitcpio.conf; then
        sudo sed -i "s/^MODULES=(/MODULES=($module /" /etc/mkinitcpio.conf
    fi
}

# Backup function
backup_file() {
    local file="$1"
    local backup_dir="$HOME/backups/installer_script/$(date +%Y-%m-%d)"
    mkdir -p "$backup_dir"
    cp "$file" "$backup_dir/$(basename $file).$(date +%H%M%S)"
}

# Update the system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S base-devel git wget polkit-kde-agent brightnessctl--noconfirm

# Install yay for AUR packages
cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $(whoami):$(whoami) yay
cd yay
makepkg -si --noconfirm

# Install NVIDIA / AMD GPU drivers and utilities
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings xf86-video-amdgpu --noconfirm
yay -S libva libva-nvidia-driver-git linux-headers --noconfirm

# Install ASUS Control and related utilities
yay -S asusctl supergfxctl power-profiles-daemon waybar-hyprland wlogout swww xdg-desktop-portal-hyprland google-chrome firefox keepass timeshift slurp grim swayidle swaylock swaync waybar gucharmap otf-font-awesome ttf-arimo-nerd noto-fonts networkmanager pycharm-community-edition --noconfirm

# Call the Pipewire installation script
source "$(pwd)/services/pipewire.sh"

# Configure NVIDIA settings for Wayland and Hyprland
backup_file "/etc/modprobe.d/nvidia.conf"
add_line_if_not_exists "/etc/modprobe.d/nvidia.conf" "options nvidia-drm modeset=1 fbdev=1"

# Add NVIDIA modules to mkinitcpio.conf
backup_file "/etc/mkinitcpio.conf"
add_module_if_not_exists "nvidia"
add_module_if_not_exists "nvidia_modeset"
add_module_if_not_exists "nvidia_uvm"
add_module_if_not_exists "nvidia_drm"

# Generate new initramfs
sudo mkinitcpio -P

# Set environment variables for Wayland
backup_file "$HOME/.bashrc"
add_line_if_not_exists "$HOME/.bashrc" 'export LIBVA_DRIVER_NAME=nvidia'
add_line_if_not_exists "$HOME/.bashrc" 'export XDG_SESSION_TYPE=wayland'
add_line_if_not_exists "$HOME/.bashrc" 'export GBM_BACKEND=nvidia-drm'
add_line_if_not_exists "$HOME/.bashrc" 'export __GLX_VENDOR_LIBRARY_NAME=nvidia'
add_line_if_not_exists "$HOME/.bashrc" 'export WLR_NO_HARDWARE_CURSORS=1'

# Create scripts directory in home folder and add it to PATH
mkdir -p "$HOME/scripts"
add_line_if_not_exists "$HOME/.bashrc" 'export PATH=$PATH:$HOME/scripts'
ln -s ~/a15/arch/dotconfig/update_dot.sh ~/scripts/update_dot.sh

# Reload bashrc
source "$HOME/.bashrc"

# Enable services for suspend and resume
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service power-profiles-daemon.service NetworkManager
# Fix for GDM login issue
sudo mkdir -p /etc/systemd/system/gdm.service.d
sudo bash -c 'echo -e "[Service]\nExecStartPre=/bin/sleep 3" > /etc/systemd/system/gdm.service.d/override.conf'

# Waybar module for keyboard status (Caps lock and Num lock) requires the user to be part of the “input” group
sudo gpasswd -a $USER input

# Reboot to apply changes
echo "Installation complete."
